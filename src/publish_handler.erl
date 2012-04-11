%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to register_app
-module(publish_handler).


-behaviour(cowboy_http_handler).


%%
%% Exported Functions
%%
-export([init/3, handle/2, terminate/2]).

%%
%% Include files
%%
-include("amqp_client.hrl").

%%
%% API Functions
%%


init({_Any, http}, Req, []) ->
	
	
	{ok, Req,  undefined }.

handle(Req, _State) ->
 	
	{App   , Req} = cowboy_http_req:binding(app  , Req),
	{Event , Req} = cowboy_http_req:binding(event, Req),
	
	{Body  , Req} = cowboy_http_req:binding(body , Req),
	
	
	
	{ok , Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok , Channel }   = amqp_connection:open_channel(Connection),


     Publish = #'basic.publish'{
				exchange =  erlmc_util:build_exchange_name(App) 
				, routing_key =   Event     
							   },
     Msg = #amqp_msg{  props =  #'P_basic'{delivery_mode = 2}  ,  
					   payload = Body},
	
	 case amqp_channel:call(Channel, Publish, Msg) of
		 ok ->
			 {ok ,Req2} = cowboy_http_req:reply(200, [], 
							<< "publish success.\r\n" >>, Req) ,
			 	amqp_channel:close(Channel),
		  	 	amqp_connection:close(Connection),
				{ok , Req2 , []};
		 Any ->
			 	error_logger:info_msg("~p",[Any]),
			 	{ok ,Req2} = cowboy_http_req:reply(200, [], 
							<< "publish error.\r\n" >>, Req) ,
			     
				{ok , Req2 , []}
	 end.


    

	


terminate(_Req, _State) ->
	ok.



%%
%% Local Functions
%%

