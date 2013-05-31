# Lets really... really... really delete cookies.
Streaming::Application.config.session_store :disabled
Streaming::Application.config.middleware.delete(ActionDispatch::Cookies)

# Have to set the base even if we disable cookies... hm...
Streaming::Application.config.secret_key_base = "abc123"
