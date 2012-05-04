-module(amqp_pool).


-export([lease/0,return/1]).

-include("../../deps/amqp_client/include/amqp_client.hrl").


lease()->
	[ { Host , Port} | _L ] = erlmc_config:rabbitmq_cluster(),
    	
	{ok , Connection} = amqp_connection:start(#amqp_params_network{
			host = Host , port = Port
		}),
	{ok , Channel }   = amqp_connection:open_channel(Connection),
	{Connection,Channel}.



return({Connection,Channel})->
	
	amqp_channel:close(Channel),
	amqp_connection:close(Connection).
	
