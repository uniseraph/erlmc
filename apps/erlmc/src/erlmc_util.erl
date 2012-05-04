%% Author: uniseraph
%% Created: 2012-4-10
%% Description: TODO: Add description to erlmc_util
-module(erlmc_util).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([build_exchange_name/1,build_exchange_name/2]).

%%
%% API Functions
%%
build_exchange_name(App)  when is_binary(App) ->
	<< 	<<"erlmc.">>/binary ,   App/binary  >> .

build_exchange_name(App,Event) when is_binary(App) , is_binary(Event) ->
	<< 	<<"erlmc.">>/binary ,   App/binary ,  <<".">>/binary ,  Event/binary    >> .


%%
%% Local Functions
%%

