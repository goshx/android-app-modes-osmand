﻿:- op('==', xfy, 500).
version(101).
language(ro).

% before each announcement (beep)
preamble - [].


%% TURNS 
turn('left', ['virați la stânga ']).
turn('left_sh', ['virați brusc la stânga ']).
turn('left_sl', ['virați ușor la stânga ']).
turn('right', ['virați la dreapta ']).
turn('right_sh', ['virați brusc la dreapta ']).
turn('right_sl', ['virați ușor la dreapta ']).
turn('right_keep', ['încadrați-vă pe partea dreaptă']).
turn('left_keep', ['încadrați-vă pe partea stângă']).

prepare_turn(Turn, Dist) == ['Pregăți-vă să ', M, ' după ', D] :- distance(Dist) == D, turn(Turn, M).
turn(Turn, Dist) == ['After ', D, M] :- distance(Dist) == D, turn(Turn, M).
turn(Turn) == M :- turn(Turn, M).

prepare_make_ut(Dist) == ['Pregăți-vă să întoarceți după ', D] :- distance(Dist) == D.
make_ut(Dist) == ['Peste ', D, ' întoarceți-vă '] :- distance(Dist) == D.
make_ut == ['Întoarceți-vă '].
make_ut_wp == ['Întoarceți-vă când aveți posibilitatea '].

prepare_roundabout(Dist) == ['Pregăți-vă să intrați în sensul giratoriu după ', D] :- distance(Dist) == D.
roundabout(Dist, _Angle, Exit) == ['Peste ', D, ' intrați în sensul giratoriu și luați-o pe ', E, 'ieșire'] :- distance(Dist) == D, nth(Exit, E).
roundabout(_Angle, Exit) == ['Luați-o pe ', E, 'ieșire'] :- nth(Exit, E).

go_ahead == ['Mergeți înainte '].
go_ahead(Dist) == ['Urmăriți drumul principal pentru ', D]:- distance(Dist) == D.

and_arrive_destination == ['și ajungeți la destinație '].

then == ['apoi '].
reached_destination == ['Ați ajuns la destinație '].
and_arrive_intermediate == ['și ajungeți la punctul intermediar '].
reached_intermediate == ['Ați ajuns la punctul intermediar '].
bear_right == ['încadrați-vă pe partea dreaptă '].
bear_left == ['încadrați-vă pe partea stângă '].

route_new_calc(Dist) == ['Lungimea traseului ', D] :- distance(Dist) == D.
route_recalc(Dist) == ['Traseu recalculat, distanța ', D] :- distance(Dist) == D.

location_lost == ['semnal gipies pierdut '].


%% 
nth(1, 'prima ').
nth(2, 'a doua ').
nth(3, 'a treia ').
nth(4, 'a patra ').
nth(5, 'a cincea ').
nth(6, 'a șasea ').
nth(7, 'a șaptea ').
nth(8, 'a opta ').
nth(9, 'a noua ').
nth(10, 'a zecea ').
nth(11, 'a unsprezecea ').
nth(12, 'a douăsprezecea ').
nth(13, 'a treisprezecea ').
nth(14, 'a paisprezecea ').
nth(15, 'a cinsprezecea ').
nth(16, 'a șaisprezecea ').
nth(17, 'a șaptesprezecea ').


distance(Dist) == D :- measure('km-m'), distance_km(Dist) == D.
distance(Dist) == D :- measure('mi-f'), distance_mi_f(Dist) == D.
distance(Dist) == D :- measure('mi-y'), distance_mi_y(Dist) == D.

%%% distance measure km/m
distance_km(Dist) == [ X, ' metri']               :- Dist < 100,   D is round(Dist/10.0)*10,           num_atom(D, X).
distance_km(Dist) == [ X, ' metri']               :- Dist < 1000,  D is round(2*Dist/100.0)*50,        num_atom(D, X).
distance_km(Dist) == ['circa un kilometru ']        :- Dist < 1500.
distance_km(Dist) == ['circa ', X, ' kilometri '] :- Dist < 10000, D is round(Dist/1000.0),            num_atom(D, X).
distance_km(Dist) == [ X, ' kilometri ']          :-               D is round(Dist/1000.0),            num_atom(D, X).

%%% distance measure mi/f
distance_mi_f(Dist) == [ X, ' picioare']               :- Dist < 160,   D is round(2*Dist/100.0/0.3048)*50, num_atom(D, X).
distance_mi_f(Dist) == [ X, ' zecime de milă']    :- Dist < 241,   D is round(Dist/161.0),             num_atom(D, X).
distance_mi_f(Dist) == [ X, ' zecimi de milă']   :- Dist < 1529,  D is round(Dist/161.0),             num_atom(D, X).
distance_mi_f(Dist) == ['circa o milă ']           :- Dist < 2414.
distance_mi_f(Dist) == ['circa ', X, ' mile ']    :- Dist < 16093, D is round(Dist/1609.0),            num_atom(D, X).
distance_mi_f(Dist) == [ X, ' mile ']             :-               D is round(Dist/1609.0),            num_atom(D, X).

%%% distance measure mi/y
distance_mi_y(Dist) == [ X, ' iarzi']              :- Dist < 241,   D is round(Dist/10.0/0.9144)*10,    num_atom(D, X).
distance_mi_y(Dist) == [ X, ' iarzi']              :- Dist < 1300,  D is round(2*Dist/100.0/0.9144)*50, num_atom(D, X).
distance_mi_y(Dist) == ['circa o milă ']           :- Dist < 2414.
distance_mi_y(Dist) == ['circa ', X, ' mile ']    :- Dist < 16093, D is round(Dist/1609.0),            num_atom(D, X).
distance_mi_y(Dist) == [ X, ' mile ']             :-               D is round(Dist/1609.0),            num_atom(D, X).


%% resolve command main method
%% if you are familar with Prolog you can input specific to the whole mechanism,
%% by adding exception cases.
flatten(X, Y) :- flatten(X, [], Y), !.
flatten([], Acc, Acc).
flatten([X|Y], Acc, Res):- flatten(Y, Acc, R), flatten(X, R, Res).
flatten(X, Acc, [X|Acc]).

resolve(X, Y) :- resolve_impl(X,Z), flatten(Z, Y).
resolve_impl([],[]).
resolve_impl([X|Rest], List) :- resolve_impl(Rest, Tail), ((X == L) -> append(L, Tail, List); List = Tail).