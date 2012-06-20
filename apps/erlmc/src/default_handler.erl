%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to default_handler
-module(default_handler).



-behaviour(cowboy_http_handler).
-include_lib("amqp_client/include/amqp_client.hrl").

-export([init/3, handle/2, terminate/2]).

init({_Any, http}, Req, []) ->
	
	
	
	
	{ok, Req, undefined}.

handle(Req, State) ->
	
	{Connection,Channel} = amqp_pool:lease(),
	
	Result = amqp_channel:register_flow_handler(Channel,self()),
	io:format("Result is ~p~n",[Result]),
	receive 
		Any -> 
			{ok, Req2} = cowboy_http_req:reply(200, [], [io_lib:format("~p~n", [Any]) ], Req)	
	end,
	
	
	{ok, Req2, State}.

terminate(_Req, _State) ->
	ok.
