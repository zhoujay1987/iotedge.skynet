local text = {
    regex = {
        host_port = "^([%w%.%-]+):?(%d*)$",
        http_host_port = "^(https?://)([%w%.%-]+):?(%d*).*$",
        websocket = "^(wss?)://([^/]+)(.*)$",
        valid_cmd = "^[%g%s]+$",
        cmd_with_table_arg = "(%g+)%s+(%g+)%s+({[%s%g]*})",
        cmd_with_arg = "(%g+)%s+(%g+)%s*(%g*)"
    },
    app = {
        unknown_cmd = "unknown command",
        no_conf_handler = "no conf handler",
        pack_fail = "pack failed",
        invalid_arg = "invalid argument",
        invalid_conf = "invalid configuration",
        conf_fail = "configure failed",
        install_fail = "install failed",
        vpn_stopped = "VPN server stopped",
        app_stopped = "APP not running"
    },
    store = {
        open_suc = "DB opened",
        open_fail = "DB open failed",
        closed = "DB closed",
        post_done = "all data re-posted",
        retire = "retire done",
        vacuum = "vacuum done",
        enable = "APP storage enabled",
        online = "APP online",
        offline = "APP offline"
    },
    modbus = {
        invalid_fc_conf = "invalid function code configuration",
        invalid_unit = "invalid device of response",
        invalid_num = "invalid number of response",
        invalid_fc = "invalid function code of response",
        invalid_addr = "invalid addr of response",
        invalid_write = "invalid write",
        exception = "exception raised",
    },
    s7 = {
        invalid_area_conf = "invalid area configuration",
        invalid_dbnumber_conf = "invalid dbnumber configuration",
        invalid_dt_conf = "invalid datatype for TM or CT area"
    },
    daq = {
        not_online = "device not online",
        poll_start = "poll started",
        poll_stop = "poll stopped",
        poll_fail = "poll failed",
        req_fail = "fetch data failed",
        read_only = "read-only tag",
        write_suc = "write done",
        invalid_transport_conf = "invalid transport configuration",
        invalid_device_conf = "invalid device configuration",
        invalid_tag_conf = "invalid tag configuration",
        invalid_addr_conf = "invalid address configuration",
        invalid_arg = "invalid argument",
        invalid_dev = "invalid device",
        invalid_tag = "invalid tag",
    },
    sysmgr = {
        unknown_cmd = "unknown command",
        config_load_suc = "config loaded",
        config_load_fail = "config load failed",
        config_removed = "config removed",
        config_update_suc = "config updated",
        config_update_fail = "config update failed",
        dup_tpl = "duplicate APP template",
        dup_app = "duplicate APP",
        download_fail = "SW download failed",
        unzip_fail = "SW unzip failed",
        invalid_meta = "invalid SW metadata",
        invalid_app = "invalid APP",
        core_replace = "core to be replaced",
        install_fail = "new system install failed",
        configure_fail = "new system configure failed",
        sys_exit = "system exited",
    },
    appmgr = {
        unknown_cmd = "unknown command",
        invalid_arg = "invalid argument",
        invalid_version = "invalid system version",
        dup_upgrade_version = "system version same as current",
        invalid_repo = "SW repository not set",
        unknown_pipe = "unknown PIPE",
        pipe_load_suc = "PIPE loaded",
        pipe_running = "PIPE is running",
        pipe_stopped = "PIPE stopped",
        pipe_start_suc = "PIPE started",
        pipe_stop_suc = "PIPE stopped",
        unknown_app = "unknown APP",
        load_suc = "APP loaded",
        load_fail = "APP load failed",
        sysapp_create = "System APP can't be created",
        sysapp_remove = "System APP can't be removed",
        syspipe_remove = "System PIPE can't be removed",
        syspipe_stop = "System PIPE can't be stopped",
        app_exit = "APP exited",
        app_readonly = "APP can't be configured",
        app_inuse = "APP used by PIPE",
        loop = "endless loop detected",
        locked = "system in maintenance",
        cleaned = "all configuration cleaned",
        app_conf = "APP configuration",
        conf_fail = "configure failed",
    },
    gateway = {
        unknown_request = "unknown device or cmd",
        invalid_dev = "invalid DEVICE name or description",
        dup_dev = "DEVICE name already used",
        dev_registered = "new DEVICE registered",
        dev_unregistered = "DEVICE unregistered",
        unknown_app = "unknown APP",
        dup_cmd = "CMD name already used",
        cmd_registered = "new CMD registered",
        no_conf = "not configured",
        new_request = "new REQUEST",
        busy = "busy"
    },
    console = {
        prompt = ">> ",
        sep = "",
        welcome = "Welcome to IoTEdge",
        tip = "help for command list",
        not_auth = "Not authorized",
        max = "Max connection reached",
        username = "Username: ",
        password = "Password: ",
        closed = "Connection closed",
        ok = "OK",
        nok = "Error"
    },
    mqtt = {
        invalid_req = "invalid request received",
        invalid_post = "invalid post received",
        dup_req = "duplicated request received",
        pack_fail = "pack failed",
        unpack_fail = "unpack failed",
        unknown_dev = "unknown device",
        pub_suc = "published",
        pub_fail = "publish failed",
        sub_suc = "subscribed",
        sub_fail = "subscribe failed",
        stop_suc = "stopped",
        stop_fail = "stop failed",
        connect_suc = "connected",
        connect_fail = "connection problem",
        configure_suc = "system configured",
        configure_fail = "system configure failed",
        no_conf = "not configured",
        error = "error happened",
        close = "closed",
        busy = "busy",
    },
}

return setmetatable({}, {
  __index = text,
  __newindex = function(t, k, v)
                 error("Attempt to modify read-only table")
               end,
  __metatable = false
})
