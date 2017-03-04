
%%% @author David Méndez <hello@davidemdot.com>
%%% @doc This module exports a function which starts N processes in a ring, and 
%%% sends a message M times around all the processes in the ring. After the 
%%% messages have been sent the processes terminate gracefully.
%%% @end

-module(ring).

-export([start/3]).

start(P, M, Msg) when P > 0, M > 0 ->
    spawn(fun() -> create_and_spread(P - 1, M, Msg, self()) end),
    ok;

start(_P, _M, _Msg) ->
    error(not_too_good_arguments).

create_and_spread(0, M, Msg, First) ->
    First ! {M - 1, Msg},
    listen_and_forward(First);

create_and_spread(P, M, Msg, First) ->
    Next = spawn(fun() -> create_and_spread(P - 1, M, Msg, First) end),
    listen_and_forward(Next).

listen_and_forward(Next) ->
    receive
        stop ->
            Next ! stop,
            ok;
        {0, _Msg} ->
            Next ! stop,
            ok;
        {M, Msg} ->
            Next ! {M - 1, Msg},
            listen_and_forward(Next);
        _ ->
            listen_and_forward(Next)
    end.
