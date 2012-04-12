-module(erlmc_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	
	 Dispatch = [
		{'_', [
	
			{[<<"register_app">>,  app   ], register_app_handler, []},
			{[<<"register_app">>,  app , persistent  ], register_app_handler, []},
			
			{[<<"register_event">>,  app , event   ], register_event_handler, []},
			{[<<"register_event">>,  app , event, persistent  ], register_event_handler, []},
			
			{[<<"publish">>,  app , event , body   ], publish_handler, []},
					
			{[<<"subscribe_event">>,  app , events  ], subscribe_handler, []},
			{[<<"subscribe_event">>,  app , events , queue ], subscribe_handler, []},
			
			{'_', default_handler, []}
		]}
	],
	cowboy:start_listener(my_http_listener, 5,
		cowboy_tcp_transport, [{port, 8080}],
		cowboy_http_protocol, [{dispatch, Dispatch}]
	),
	
	
	
    erlmc_sup:start_link().

stop(_State) ->
    ok.
