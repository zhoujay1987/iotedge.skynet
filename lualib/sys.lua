local skynet = require "skynet"
local dns = require "skynet.dns"

local install_cmd = "scripts/install.sh"
local uninstall_cmd = "scripts/uninstall.sh"

local function execute(cmd)
    local ok, exit, errno = os.execute(cmd)
    if ok and exit == "exit" and errno == 0 then
        return true
    else
        return false
    end
end

local sys = {
    ssh_port = 22,
    ws_proxy_port = 29999,
    console_port = 30000,
    ws_port = 30001,
    sys_root = "sys",
    app_root = "app",
    run_root = "run",
    db_root = "db",
    sys_cfg = "config",
    repo_cfg = "repo",
    pipe_cfg = "pipe",
    meta_lua = "meta",
    entry_lua = "entry",
    gateway_global = "iotedge-gateway",
}

function sys.exec(cmd)
    if type(cmd) == "string" then
        return execute(cmd)
    else
        return false
    end
end

function sys.exec_with_return(cmd)
    if type(cmd) == "string" then
        local f = io.popen(cmd)
        if f then
            local s = f:read("a")
            if s ~= "" then
                f:close()
                return s
            else
                f:close()
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function sys.resolve(hostname)
    if hostname:match("^[%.%d]+$") then
        return hostname
    else
        local ok, ret = pcall(dns.resolve, hostname)
        if ok then
            return ret
        else
            return ok
        end
    end
end

function sys.prod()
    if skynet.getenv("loglevel"):match("INFO") then
        return true
    else
        return false
    end
end

function sys.quit()
    if sys.prod() then
        execute(uninstall_cmd)
    else
        skynet.abort()
    end
end

function sys.unzip(f, dir)
    if not dir then
        dir = "."
    end
    return execute("tar -C "..dir.." -xzf "..f)
end

function sys.upgrade(config, dir, port)
    return execute(table.concat({install_cmd, "upgrade", config, dir, port}, " "))
end

function sys.core_name(version)
    return string.format("%s-%s", "iotedge", version)
end

function sys.app_uri(uri, platform, name)
    if name then
        name = name:match("(.+)_v_.+")
    else
        name = "core"
    end
    return string.format("%s/%s/%s/", uri, platform, name)
end

function sys.app_tarball(name)
    local n = name:match(".+_(v_.+)")
    if not n then
        n = name
    end
    return n..".tar.gz"
end

function sys.memlimit()
    local limit = skynet.getenv("memlimit")
    if limit then
        return tonumber(limit)
    else
        return nil
    end
end

------------------------------------------
local function handle_svc(cmd, svc)
    local c = string.format("systemctl %s %s >/dev/null 2>&1", cmd, svc)
    local suc = string.format("%s %s successfully", cmd, svc)
    local fail = string.format("%s %s failed", cmd, svc)
    local ok  = execute(c)
    if ok then
        return ok, suc
    else
        return ok, fail
    end
end

function sys.enable_svc(svc)
    return handle_svc("enable", svc)
end

function sys.disable_svc(svc)
    return handle_svc("disable", svc)
end

function sys.stop_svc(svc)
    return handle_svc("stop", svc)
end

function sys.start_svc(svc)
    handle_svc("restart", svc)
    skynet.sleep(20)
    return handle_svc("status", svc)
end

function sys.reload_svc(svc)
    handle_svc("reload", svc)
    skynet.sleep(20)
    return handle_svc("status", svc)
end

------------------------------------------
return setmetatable({}, {
  __index = sys,
  __newindex = function(t, k, v)
                 error("Attempt to modify read-only table")
               end,
  __metatable = false
})
