%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to register_app
-module(publish_handler).


%-behaviour(cowboy_http_handler).


%%
%% Exported Functions
%%
-export([init/3,  terminate/2]).
-export([info/3]).
%-export([handle/2]).
%%
%% Include files
%%
-include("amqp_client.hrl").
-include("http.hrl").
-record(state,{channel,connection,noreply=true}).
%%
%% API Functions
%%


init({_Any, http}, Req, []) ->

	{App   , Req1} = cowboy_http_req:binding(app  , Req),
	{Event , Req2} = cowboy_http_req:binding(event, Req1),
	{Body  , Req3} = cowboy_http_req:binding(body , Req2),
	
	

    {ok , Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok , Channel }   = amqp_connection:open_channel(Connection),



	ok =  amqp_channel:register_return_handler(Channel, self()),
	ok =  amqp_channel:register_confirm_handler(Channel, self()),
	
	Publish = #'basic.publish'{
			exchange =  erlmc_util:build_exchange_name(App) ,
			mandatory = true,		
			routing_key =   Event
			},
     	Msg = #amqp_msg{  props =  #'P_basic'{delivery_mode = 2}  ,  
			   payload = Body},
        
	amqp_channel:cast(Channel,Publish,Msg),
	{ loop , Req3 , #state{connection=Connection,channel=Channel} , 100 } .
     


info( { #'basic.return'{reply_code=ReplyCode,reply_text=ReplyText} , _ } = Message  ,  Req , State ) ->
	error_logger:info_msg("~p recving a message ~p~n", [self(), Message]) ,
	{ok,Req2} =cowboy_http_req:reply(200, [] ,  ["publish error ," , ReplyText , "\r\n" ] , Req   ),
	{ok , Req2 , State#state{noreply=false} };
info(Message , Req, State) ->
	error_logger:info_msg("~p recving a message ~p~n", [self(), Message]) ,
	{loop , Req , State} .

	



terminate(Req=#http_req{resp_state=RespState}, #state{connection=Connection,channel=Channel  , noreply =NoReply }) ->
    case   NoReply of 
		true ->
			 %greate hack
	 		 cowboy_http_req:reply(200, [],	<< "publish success\r\n" >>, Req#http_req{resp_state=waiting}) ;
		false ->
			ok
	end,
	amqp_channel:close(Channel),
	amqp_connection:close(Connection),
	ok.




%%
%% Local Functions
%%





















