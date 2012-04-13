%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to register_app
-module(subscribe_ex_handler).


%-behaviour(cowboy_http_handler).


%%
%% Exported Functions
%%
-export([init/3, terminate/2 , info/3]).

%%
%% Include files
%%
-include("amqp_client.hrl").
-include("http.hrl").

%%
%% API Functions
%%

-record(state ,  { app , events , channel , connection , ctag , queue }) .

init({_Any, http}, Req=#http_req{socket=Socket}, []) ->
	
	{ App ,   Req } = cowboy_http_req:binding(app,Req),
	{ Events , Req } = cowboy_http_req:binding(events,Req),
	{ Queue , Req } = cowboy_http_req:binding(queue,Req,undefined),
	%{ Durable , Req} = cowboy_http_req:binding(events,Req , << "true" >>),
	
	%% TODO  : get the history message 
	{ok , Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok , Channel }   = amqp_connection:open_channel(Connection , { amqp_direct_consumer , [self()] }),


        Q = case  Queue of
		undefined ->
			#'queue.declare_ok'{queue = X } = 
				amqp_channel:call(Channel, #'queue.declare'{
				durable= true
				} ),
			X;
		_ ->
			Queue
	end	,

	
	
	Headers = [{'Content-Type', <<"text/event-stream">>}],
	{ok, Req2} = cowboy_http_req:chunked_reply(200, Headers, Req),
	ok = cowboy_http_req:chunk( [ "queue=", Q , "\r\nreceving ....."  , "\r\n"] , Req2 ),
	
  
	 
	  lists:foreach( fun(Event) -> 
			% binding the queue to the exchange 
       		Binding = #'queue.bind'{queue       = Q,
                         exchange    = erlmc_util:build_exchange_name(App, Event)  
					  },
			%%暂时不考虑binding失败的情况
       		#'queue.bind_ok'{} = amqp_channel:call(Channel, Binding)
		end , binary:split(Events , <<",">>) ),

	
       Sub = #'basic.consume'{queue = Q ,no_ack= false},
       #'basic.consume_ok'{consumer_tag = Ctag} = amqp_channel:call(Channel, Sub),
	
	   cowboy_tcp_transport:setopts(Socket, [{active, once}]), 
	
	   {loop , Req2,  #state{app=App,events=binary:split(Events , <<",">>), channel=Channel, 
					  	 connection=Connection,ctag=Ctag , queue=Queue}  , hibernate}.


info({tcp_closed , _ } , 
	 	Req = #http_req{socket=_Socket} ,	
	 	State=#state {connection=Connection,channel=Channel ,ctag=Ctag,queue=Queue}) ->
%	amqp_channel:call(Channel, #'basic.cancel'{consumer_tag = Ctag}) ,
%	amqp_channel:call(Channel, #'queue.delete'{queue=Queue}) ,
	amqp_channel:close(Channel),
	amqp_connection:close(Connection),
	{ok , Req, State} ;

info( { #'basic.consume_ok'{} , Ctag}  , Req= #http_req{socket=Socket}  , State = #state{ctag=Ctag} ) ->
	cowboy_tcp_transport:setopts(Socket, [{active, once}]), 
	{loop , Req , State , hibernate} ;

info(  {#'basic.deliver'{delivery_tag = Dtag}, #amqp_msg{payload=Payload}}   , 
	   Req= #http_req{socket=Socket}  ,  State =#state{channel=Channel} )  ->
	cowboy_tcp_transport:setopts(Socket, [{active, once}]), 

	ok = cowboy_http_req:chunk( [Payload, "\r\n"] , Req ),
        amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Dtag}),
	{loop,Req, State ,hibernate};

info(_Message, Req= #http_req{socket=Socket} ,State) ->
	cowboy_tcp_transport:setopts(Socket, [{active, once}]), 
	{loop , Req , State , hibernate} .
	


	


terminate(_Req, _State=#state{connection=_Connection,channel=_Channel}) ->
%	error_logger:info_msg("~p terminate~n",[self()]),
	ok.



%%
%% Local Functions
%%

