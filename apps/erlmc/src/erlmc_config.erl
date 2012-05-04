-module(erlmc_config).


-export([rabbitmq_cluster/0]).



rabbitmq_cluster()->
	case  application:get_env(erlmc, rabbitmq_cluster) of
		{ok , Cluster } ->
			Cluster;
		undefined ->
			{ "127.0.0.1" ,5672}
	end.
