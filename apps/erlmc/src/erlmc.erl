%% Author: uniseraph
%% Created: 2012-4-9
%% Description: TODO: Add description to erlmc
-module(erlmc).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start/0]).

%%
%% API Functions
%%


start()->
	application:start(cowboy),
	application:start(erlmc).
	
	
%%
%% Local Functions
%%

