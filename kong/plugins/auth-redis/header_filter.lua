local redis = require "resty.redis"

local _M = {}

function _M.execute(conf, ngx)

-- Get request Header and check if exist
  local ngx_headers = kong.request.get_headers()
  local auth, err = ngx_headers["Authorization"] 
  if not auth and conf.allow_anonymous == 0 then -- 1 = Allow anonymous forward request, 0 = Disallow, return 401 as default
    return kong.response.exit(401, { message = "Unauthorized" })
  end 

  if not auth and conf.allow_anonymous == 1 then
    kong.service.request.clear_header("Authorization")
    return
  end

-- Init Redis connection
  local red = redis:new()
  red:set_timeout(conf.redis_timeout)
  
-- Connect to redis
  local ok, err = red:connect(conf.redis_host, conf.redis_port)
  if not ok then
    return kong.response.exit(503, "Service Temporarily Unavailable")
  end
  -- end

-- Auth Redis connection with password
  if conf.redis_password and conf.redis_password ~= "" then
    local ok, err = red:auth(conf.redis_password)
    if not ok then
      return kong.response.exit(503, "Service Temporarily Unavailable")
    end
  end

-- Query token in Redis 
  local token 
  if string.len(conf.redis_token_prefix) > 0 then 
    token = conf.redis_token_prefix .. ":" .. string.sub(auth, 8)
  else
    token = string.sub(auth, 8)
  end

  local verify, err = red:get(token)
  kong.log("verify", verify);
  if err then
    return kong.response.exit(503, "Service Temporarily Unavailable")
  end
  if not verify then
    return kong.response.exit(503, "Service Temporarily Unavailable")
  end

-- Keep Established Redis connection 
  local ok, err = red:set_keepalive(60000,5000)
  if not ok then
    kong.log.err("failed to set Redis keepalive: ", err)
  end
  
  if verify == ngx.null then
    return kong.response.exit(401, { message = "Unauthorized" })
  elseif conf.allow_anonymous == 1 then
    kong.service.request.clear_header("Authorization")
    return
  else
    kong.service.request.set_header("Authorization", "Bearer " .. verify)
  end
  
--   Close Redis connection 
--   local ok, err = red:close()
end

return _M