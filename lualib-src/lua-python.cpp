#include <Python.h>

#define SOL_ALL_SAFETIES_ON 1

#ifdef CXX17
#include "sol3.hpp"
#else
#include "sol2.hpp"
#endif

namespace python {

#define RETURN_OK(R) R.push_back({ L, sol::in_place_type<bool>, true });

#define RETURN_VALUE(R, T, V) { \
	R.push_back({ L, sol::in_place_type<T>, V }); \
}

#define RETURN_ERROR(R, E) { \
    R.push_back({ L, sol::in_place_type<bool>, false }); \
	R.push_back({ L, sol::in_place_type<std::string>, E }); \
}

    const std::string errNotInit = "Not initialized";
    const std::string errUnknownModule = "Unknown module";
    const std::string errUnknownFunction = "Unknown function";
    const std::string errInvalidArgs = "Invalid arguments";
    const std::string errFunction = "Err execute function";

    PyObject* convertArg(const sol::object& Obj) {
        sol::type t = Obj.get_type();
        switch (t) {
            case sol::type::boolean:
                {
                    return Obj.as<bool>() ? Py_True : Py_False;
                }
            case sol::type::string:
                {
                    const std::string& v = Obj.as<std::string>();
                    return PyUnicode_FromStringAndSize(v.data(), v.length());
                }
            case sol::type::number:
                {
                    if (Obj.is<int64_t>())
                        return PyLong_FromLong(Obj.as<int64_t>());
                    else
                        return PyFloat_FromDouble(Obj.as<double>());
                }
            default:
                return NULL;
        }
    }

    void Init(const std::string& Path) {
        if (Py_IsInitialized())
            Py_FinalizeEx();

        PyObject *pSyspath=NULL, *pPath=NULL;
        pSyspath = PySys_GetObject("path");
        PyObject_Print(pSyspath, stdout, 0);

        pPath = PyUnicode_FromStringAndSize(Path.data(), Path.length());
        PyObject_Print(pPath, stdout, 0);

        PyList_Insert(pSyspath, 1, pPath);
        PySys_SetObject("path", pSyspath);

        pSyspath = PySys_GetObject("path");
        PyObject_Print(pSyspath, stdout, 0);

        Py_XDECREF(pSyspath);
        Py_XDECREF(pPath);

        Py_Initialize();
    }

    auto Run(const std::string& Module,
            const std::string& Func,
            sol::table Args,
            sol::this_state L) {

        sol::variadic_results ret;
        PyObject *pName=NULL, *pModule=NULL, *pFunc=NULL, *pArgs=NULL, *pValue=NULL;
        size_t size = Args.size();

        if (!Py_IsInitialized()) {
            RETURN_ERROR(ret, errNotInit)
            goto DONE;
        }

        pName = PyUnicode_DecodeFSDefaultAndSize(Module.data(), Module.length());
        pModule = PyImport_Import(pName);

        if (!pModule) {
            RETURN_ERROR(ret, errUnknownModule)
            goto DONE;
        }

        pFunc = PyObject_GetAttrString(pModule, Func.data());
        if (!pFunc || !PyCallable_Check(pFunc)) {
            RETURN_ERROR(ret, errUnknownFunction)
            goto DONE;
        }

        pArgs = PyTuple_New(size);
        for(size_t i = 0, j = 1; i != size; i++, j++) {
            pValue = convertArg(Args[j]);
            if (!pValue) {
                RETURN_ERROR(ret, errInvalidArgs)
                goto DONE;
            }
            PyTuple_SetItem(pArgs, i, pValue);
        }

        pValue = PyObject_CallObject(pFunc, pArgs);
        if (pValue) {
            RETURN_OK(ret)
            RETURN_VALUE(ret, int64_t, PyLong_AsLongLong(pValue))
        }
        else {
            RETURN_ERROR(ret, errFunction)
        }

DONE:
        Py_XDECREF(pName);
        Py_XDECREF(pModule);
        Py_XDECREF(pFunc);
        Py_XDECREF(pArgs);
        Py_XDECREF(pValue);
        return ret;
    }

    sol::table Open(sol::this_state L) {
        sol::state_view lua(L);
        sol::table module = lua.create_table();

        module.set_function("init", Init);
        module.set_function("close", Py_FinalizeEx);
        module.set_function("run", Run);

        return module;
    }
}

extern "C" int luaopen_python(lua_State *L) {
    return sol::stack::call_lua(L, 1, python::Open);
}
