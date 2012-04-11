%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to register_app
-module(register_event_handler).


%-behaviour(cowboy_http_handler).


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

handle(Req, State) ->
	{App , Req} = cowboy_http_req:binding(app, Req),
	{Event , Req} = cowboy_http_req:binding(event, Req),
	{Persistent , Req} = cowboy_http_req:binding(persistent, Req , <<"true">>),
	
	{ok , Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok , Channel }   = amqp_connection:open_channel(Connection),

	DestName= erlmc_util:build_exchange_name(App, Event) ,
	SourceName = erlmc_util:build_exchange_name(App),

	Declare = #'exchange.declare'{
		exchange= DestName  ,
		durable = case Persistent of  <<"true">> ->   true ;  _ -> false   end 
		,type= <<  "fanout"  >>				
	},
	
    try
	  		#'exchange.declare_ok'{} = amqp_channel:call(Channel,Declare), 
		 	
			Binding =#'exchange.bind'{
					destination = DestName,
					source =  SourceName,
					routing_key = Event 
			},
			
			#'exchange.bind_ok'{} = amqp_channel:call(Channel,Binding) ,
			
		  	{ok ,Req2} = cowboy_http_req:reply(200, [], 
						<< "register the event success.\r\n" >>, Req) ,
			{ok,Req2,State}
	catch
		   exit:Why ->
		   {ok , Req3} = cowboy_http_req:reply(200,[], 
								list_to_binary(io_lib:format("~p~n",[Why]))   ,
								Req ),
		   {ok , Req3,State}			

	after
		   amqp_connection:close(Connection)	
	end.
	

	

	
 






	


terminate(_Req, _State) ->
	ok.



%%
%% Local Functions
%%

