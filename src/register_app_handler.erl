%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to register_app
-module(register_app_handler).


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

handle(Req, State) ->
 	
	{App , Req} = cowboy_http_req:binding(app, Req),
	{Persistent , Req} = cowboy_http_req:binding(persistent, Req , <<"true">>),
	
	
	{ok , Connection} = amqp_connection:start(#amqp_params_network{}),
	{ok , Channel }   = amqp_connection:open_channel(Connection),

	Declare = #'exchange.declare'{
		exchange=  erlmc_util:build_exchange_name(App) ,
		durable = case Persistent of  <<"true">> ->   true ;  _ -> false   end
        ,type= <<"topic">>				
	},
	

        try
		  case  amqp_channel:call(Channel,Declare) of
				#'exchange.declare_ok'{} -> 
		  				{ok ,Req2} = cowboy_http_req:reply(200, [], 
							<< "register the app success.\r\n" >>, Req) ,
		  				{ok, Req2, State} 
		  end
	catch
		   exit:{Why,_} ->
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

