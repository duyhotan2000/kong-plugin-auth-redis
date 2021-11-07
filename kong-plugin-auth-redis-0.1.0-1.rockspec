local plugin_name = "auth-redis"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "0.1.0"
local rockspec_revision = "1"

local github_account_name = "Kong"
local github_repo_name = "kong-plugin"
local git_checkout = package_version == "dev" and "master" or package_version


package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }
source = {
  url = "git://github.com/"..github_account_name.."/"..github_repo_name..".git",
}


description = {
  summary = "A Kong plugin that Authorize access token using Redis as a token datastore",
  license = "Apache V2"
}


dependencies = {
  "lua >= 5.1",
  "lua-resty-redis >= 0.26.0"
}


build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..plugin_name..".handler"] = "kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "kong/plugins/"..plugin_name.."/schema.lua",
    ["kong.plugins."..plugin_name..".header_filter"] = "kong/plugins/"..plugin_name.."/header_filter.lua",
  }
}