%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to register_app
-module(publish_handler).


%-behaviour(cowboy_http_handler).


%%
%% Exported Functions
%%
-export([init/3,  terminate/2]).
-export([handle/2]).
%%
%% Include files
%%
-include("amqp_client.hrl").

%%
%% API Functions
%%


init({_Any, http}, Req, []) ->
   {ok , Req, [] }.

handle(Req,State)->
	{App   , Req} = cowboy_http_req:binding(app  , Req),
	{Event , Req} = cowboy_http_req:binding(event, Req),
	{Body  , Req} = cowboy_http_req:binding(body , Req),
	
	

       	{ok , Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok , Channel }   = amqp_connection:open_channel(Connection),

	 MonitorRef =     erlang:monitor(process,Channel) ,


	ok =  amqp_channel:register_return_handler(Channel, self()),

	Publish = #'basic.publish'{
			exchange =  erlmc_util:build_exchange_name(App) ,
			mandatory = true,		
			routing_key =   Event
			},
     	Msg = #amqp_msg{  props =  #'P_basic'{delivery_mode = 2}  ,  
			   payload = Body},
        
	amqp_channel:cast(Channel,Publish,Msg),
	{ok,Req2} = cowboy_http_req:reply(200,[] , <<"publish success\r\n">> , Req),
	{ok , Req2,  {Connection,Channel,MonitorRef} } .

     





	



    

	


terminate(_Req, {Connection,Channel,MonitorRef}) ->
	error_logger:info_msg("~p terminate~n",[self()]),
 	amqp_channel:close(Channel),
	amqp_connection:close(Connection),
	ok.



%%
%% Local Functions
%%

