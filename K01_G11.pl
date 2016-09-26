/* Nama File : K01_G11.pl */
/* Tio In The Shining Knight - Adventure Game */

/* Game loop, begin if user types start */
game_loop 					:- 	repeat,
			 					write('<story console>'), 
								spasi(2),
			 					read(X),
			 					execute(X),
								(princess_saved; X==quit), !.

/* implementasi fungsi execute */
execute(look) 				:- look, writeln(''), !.
execute(sleeping) 			:- sleeping, writeln(''), !.
execute(readmap) 			:- readmap, writeln(''), !.
execute(goto(Place)) 		:- goto(Place), writeln(''), !.
execute(take(Object)) 		:- take(Object), writeln(''), !.
execute(sharpen(Object))	:- sharpen(Object), writeln(''),!.
execute(quit) 				:- quit, writeln(''), !.
execute(_)					:- writeln('Invalid inputs, try again.'), writeln('').

/* Predikat yang menyebabkan game loop berakhir */

princess_saved 				:- inventory(princess), writeln('Congratulations Tio has found his true love'), retractall(currentlocation(X)), retractall(inventory(X)), retractall(sharpened(X)), !.

quit 						:- writeln('Satria gives up. You quit the game, game is terminated.'), retractall(currentlocation(X)), retractall(inventory(X)), retractall(sharpened(X)), !.

/* Fakta yang menggambarkan dunia game*/

/* Fakta statis, yaitu fakta yang tidak akan berubah (termasuk static list) */
list(room,[dragon_treasury,armory,castle,bedroom]).
list(bedroom, [bed]).
list(castle, [armor, shield, maps]).
list(armory, [desk, sword]).
list(dragon_treasury, [princess]).
list(sharp,[sword]).

door(bedroom,castle).
door(castle,armory).
door(armory,dragon_treasury).

/* Fakta dinamis, yaitu fakta yang dapat berubah seiring game berjalan */
dynamic_facts 				:- retractall(currentlocation(X)), retractall(inventory(X)), retractall(sharpened(X)),assertz(currentlocation(castle)), assertz(inventory(clothes)), assertz(sharpened(knife)). 

/* Rules */
writeln(X)					:- write(X), nl.
spasi(X) 					:- tab(X).
separator  					:- write('|').

isMember(X,[X|_]).
isMember(X,[Y|Z]) 			:- X\==Y, isMember(X,Z).	

addElmt(X,Y,[X|Y]).

delElmt(_,[],[]).
delElmt(X,[X|Xs],Xs).
delElmt(X,[Y|Xs],[Y|Ys])	:- X\==Y, delElmt(X,Xs,Ys).

isRoom(X) 					:- list(room,List), isMember(X,List).
isSharpened(X)				:- list(sharpened,List), isMember(X,List).
can_be_sharpen(X)			:- list(sharp,List), isMember(X,List).

objectlocation(X,Y)			:- list(Y,List), isMember(X,List).

connected(X,Y) 				:- isRoom(X), isRoom(Y), door(X,Y).
connected(X,Y) 				:- isRoom(X), isRoom(Y), door(Y,X).

reachable(Room2)			:- currentlocation(Room1), connected(Room1,Room2).

list_objects(Room)			:- forall( (objectlocation(Obj,Room), \+inventory(Obj)), (write(Obj), spasi(1)) ).
list_inventory				:- forall( (inventory(Obj), Obj\==clothes), (write(Obj), spasi(1)) ).
list_room					:- forall( isRoom(Room), (write(Room), spasi(1), separator, spasi(1)) ).

move(Room) 					:- X\==Room,retract(currentlocation(X)), asserta(currentlocation(Room)).

cant_save_princess_why 		:- 	writeln('You cannot save princess because of one of these things listed below :'), 
								writeln('1. You don`t have armor'), 
								writeln('2. You don`t have shield'), 
								writeln('3. You don`t have sword'),
								writeln('4. You have sword but your sword hasn`t been sharpened').

/* Commands */

/* Start akan memanggil fakta dinamis, memulai game loop, dan menjelaskan petunjuk dari game ini */
start 			:-	writeln('Welcome to Tio`s world where anything is made up and nothing holds an importance!'),
					writeln('Your job is to find Princess for Tio the Knight in Shining Armor by exploring this nonsense world!'),
					writeln('You can explore by using command:'),
					writeln('- look'),
					writeln('- sleeping'),
					writeln('- readmap'),
					writeln('- goto(place)'),
					writeln('- take(object)'),
					writeln('- sharpen(object)'),
					writeln('- quit'),
					writeln(''),
					dynamic_facts,
					game_loop. 


look 			:- 	currentlocation(Y), 
					write('You are in'), spasi(1), writeln(Y), spasi(2), 
					write('You can see:'), spasi(1), list_objects(Y), writeln(''), spasi(2),
					write('Your inventory:'), spasi(1), list_inventory, writeln('').

sleeping 		:- 	currentlocation(bedroom), write('Have a good night O Tio, Knight in Shining Armor'), writeln('').
sleeping 		:- 	\+currentlocation(bedroom), write('You can only sleep in bedroom'), writeln('').

readmap			:- 	inventory(maps),  writeln('You open the wonderful map and see whats inside'), list_room, writeln('').
readmap			:- 	\+inventory(maps),  write('You can`t read'), spasi(1), write(maps), spasi(1), write('because you don`t have it'), writeln('').

goto(Room) 		:- 	currentlocation(Room), write('That room is already your current location'), writeln(''), !.
goto(Room) 		:- 	isRoom(Room), currentlocation(Room_temp), Room\==Room_temp, \+connected(Room,Room_temp), write('You can`t get to'), spasi(1), write(Room), spasi(1), write('from your current location'), writeln(''), !.
goto(Room) 		:- 	\+isRoom(Room), writeln('Sorry your input is not room.'),!.
goto(Room) 		:- 	reachable(Room), move(Room), look.

take(Obj)		:- 	inventory(Obj), write('You already have'), spasi(1), write(Obj), writeln(''), !.
take(Obj) 		:- 	currentlocation(Room), \+objectlocation(Obj,Room), write(Obj), spasi(1), write('not found in the room'), writeln(''), !.
take(Obj) 		:- 	currentlocation(Room), objectlocation(Obj,Room), Obj\==princess, asserta(inventory(Obj)), write('You have taken a'), spasi(1), write(Obj), writeln(''), !.
take(Obj)		:- 	currentlocation(Room), objectlocation(Obj,Room), Obj == princess, \+inventory(armor), cant_save_princess_why, !.
take(Obj)		:- 	currentlocation(Room), objectlocation(Obj,Room), Obj == princess, \+inventory(shield), cant_save_princess_why, !.
take(Obj)		:- 	currentlocation(Room), objectlocation(Obj,Room), Obj == princess, \+inventory(sword), cant_save_princess_why, !.
take(Obj)		:- 	currentlocation(Room), objectlocation(Obj,Room), Obj == princess, inventory(sword), \+sharpened(sword), cant_save_princess_why, !.
take(Obj)		:- 	currentlocation(Room), objectlocation(Obj,Room), Obj == princess, inventory(armor), inventory(shield), inventory(sword), asserta(inventory(Obj)).

sharpen(Obj) 	:- 	can_be_sharpen(Obj), inventory(Obj), asserta(sharpened(Obj)), write('Your'), spasi(1), write(Obj), spasi(1), write('has been sharpened'), writeln(''), !.
sharpen(Obj) 	:- 	\+can_be_sharpen(Obj), write('This object ('), write(Obj), write(') can`t be sharpened'), writeln(''), !.
sharpen(Obj) 	:- 	\+inventory(Obj), write('You don`t have'), spasi(1), write(Obj), writeln('').
