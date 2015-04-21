/*
TO BE USED ON NODEJS SERVER
 */

/* To export from node using Browserify: http://browserify.org/

from terminal:
browserify -r ecdsa -r crypto -r secure-random -r aes -r coinkey -r buffer -r binstring -r pbkdf2-sha256 node_main.js > ecdsa_bundle.js

*/

/*
var crypto = require('crypto');
var ecdsa = require('ecdsa');
var secureRandom = require('secure-random');
var CoinKey = require('coinkey');
var Buffer = require('buffer');
var binString = require('binstring');
var AES = require('aes');
var pbkdf2 = require('pbkdf2-sha256');
var BigInteger = require('bigi');
*/