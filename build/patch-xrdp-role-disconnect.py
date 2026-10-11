#!/usr/bin/env python3
import pathlib
import sys

path = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "/tmp/xrdp/sesman/sesexec/session.c")
text = path.read_text()

marker = """/******************************************************************************/\nstatic struct list *\nprepare_xorg_xserver_params(const struct session_parameters *s,\n                            const char *authfile)\n{\n"""
helper = r'''/******************************************************************************/
/*
 * Return non-zero when this login belongs to an administrator whose
 * disconnected XRDP session should be kept alive. The role and feature flag
 * are written by the container entrypoint before xrdp-sesman starts.
 */
static int
keep_disconnected_admin_session(const struct login_info *login_info)
{
    char role_file[512];
    char role[32] = {0};
    char enabled[8] = {0};
    int fd;
    int len;

    fd = g_file_open_ro("/etc/ubuntu-xrdp/keep-admin-sessions");
    if (fd < 0)
    {
        return 0;
    }
    len = g_file_read(fd, enabled, sizeof(enabled) - 1);
    g_file_close(fd);
    if (len <= 0 || enabled[0] != '1')
    {
        return 0;
    }

    g_snprintf(role_file, sizeof(role_file),
               "/etc/ubuntu-xrdp/user-roles/%s", login_info->username);
    fd = g_file_open_ro(role_file);
    if (fd < 0)
    {
        return 0;
    }
    len = g_file_read(fd, role, sizeof(role) - 1);
    g_file_close(fd);

    return len >= 5 && g_strncmp(role, "admin", 5) == 0;
}

/******************************************************************************/
static struct list *
prepare_xorg_xserver_params(struct login_info *login_info,
                            const struct session_parameters *s,
                            const char *authfile)
{
'''
if text.count(marker) != 1:
    raise SystemExit("prepare_xorg_xserver_params marker not found exactly once")
text = text.replace(marker, helper, 1)

old_vars = '''        g_snprintf(text, sizeof(text), "%d", g_cfg->sess.max_idle_time);\n        g_setenv_log("XRDP_SESMAN_MAX_IDLE_TIME", text, 1);\n\n        g_snprintf(text, sizeof(text), "%d", g_cfg->sess.max_disc_time);\n        g_setenv_log("XRDP_SESMAN_MAX_DISC_TIME", text, 1);\n\n        g_snprintf(text, sizeof(text), "%d", g_cfg->sess.kill_disconnected);\n        g_setenv_log("XRDP_SESMAN_KILL_DISCONNECTED", text, 1);\n'''
new_vars = '''        g_snprintf(text, sizeof(text), "%d", g_cfg->sess.max_idle_time);\n        g_setenv_log("XRDP_SESMAN_MAX_IDLE_TIME", text, 1);\n\n        int max_disc_time = g_cfg->sess.max_disc_time;\n        int kill_disconnected = g_cfg->sess.kill_disconnected;\n        if (keep_disconnected_admin_session(login_info))\n        {\n            max_disc_time = 0;\n            kill_disconnected = 0;\n            LOG(LOG_LEVEL_INFO,\n                "Keeping disconnected administrator session alive for %s",\n                login_info->username);\n        }\n\n        g_snprintf(text, sizeof(text), "%d", max_disc_time);\n        g_setenv_log("XRDP_SESMAN_MAX_DISC_TIME", text, 1);\n\n        g_snprintf(text, sizeof(text), "%d", kill_disconnected);\n        g_setenv_log("XRDP_SESMAN_KILL_DISCONNECTED", text, 1);\n'''
if text.count(old_vars) != 1:
    raise SystemExit("XRDP disconnect environment block not found exactly once")
text = text.replace(old_vars, new_vars, 1)

old_call = "xserver_params = prepare_xorg_xserver_params(s, authfile);"
new_call = "xserver_params = prepare_xorg_xserver_params(login_info, s, authfile);"
if text.count(old_call) != 1:
    raise SystemExit("prepare_xorg_xserver_params call not found exactly once")
text = text.replace(old_call, new_call, 1)

path.write_text(text)
print(f"Patched role-aware XRDP disconnect handling in {path}")
