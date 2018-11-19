/*
 *  console.js
 *  
 *  A simple console for debugging JavaScript applications.
 *  
 *  Use
 *  
 *     <SCRIPT SRC="console.js"></SCRIPT>
 *
 *  within your HTML document to load the code.  Then use
 *  
 *     <SCRIPT> debug('your message here'); </SCRIPT>
 * 
 *  to send a message to the console window.  Note that the window
 *  will not open until the first message is sent to it, so use
 *  
 *     <SCRIPT SRC="console.js"></SCRIPT>
 *     <SCRIPT> debug() </SCRIPT>
 *  
 *  to load the console program and open a blank console window.
 *  
 *  You can use the debug() command within your JavaScript code to send
 *  messages to the console window at any time.
 *  
 *  The console has a type-in area where you can type JavaScript commands
 *  interactively.  When you do, their output will appear in the console
 *  window.
 *  
 *  Two commands are defined that may be of use in debugging your JavaScript
 *  programs:
 *  
 *      show(object)       returns a string that lists all the
 *                         fields contained in a JavaScript object
 *                         e.g., entering show(window.document) in the
 *                         console type-in area will display the
 *                         current window's document object in the
 *                         console window.
 *                                 
 *     attach(window)      sets the console's execution context to be
 *                         the given window.  The commands entered in the
 *                         type-in area will be executed within the scope
 *                         of the specified window.  Note that you should
 *                         not close the attached window, or you will not
 *                         be able to execute additional commands.
 *  
 *  ---------------------------------------------------------------------
 *
 *  console.js is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  console.js is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with console.js; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

var _console = {

  window: null,               // active console window
  target: 'jsConsole',        // name of window to use for console
  buffer: [],                 // buffer for output until console is open
  open: 0,                    // true when console is up and running
  
  /*************************************************************************/
  
  start: function (message) {
    _console.window =
       window.open(_console.root + "console.html",_console.target,
                   "width=700,height=350,resizable,"+
                   "toolbar=no,titlebar=no,location=no,menubar=no");
    if (message != null && message != "") {_console.buffer[_console.buffer.length] = message}
  },

  debug: function (message) {
    if (_console.window && _console.window.closed) {_console.window = null}
    if (!_console.window) {_console.start(message)}
    else if (message == null) {_console.sendMessage('NULL')}
    else if (!_console.open) {_console.buffer[_console.buffer.length] = message}
    else {_console.sendMessage('OK',message)}
  },
  
  run: function (cmd) {
    if (cmd == "") {return ['HR','']}
    try {return ['OK',eval(cmd)]} catch (err) {
         return ['ERR',(err.description != null ? err.description : err.message)];
    }
  },
  
  attach: function (w) {
    if (w == null) {w = window}
    else if (typeof(w) == 'string') {w = window.open("",w)}
    if (w != window) {
      _console.sendMessage('ATT',_console.target,w);
    } else {
      _console.sendMessage('TTL',w.document.title);
      _console.sendMessage('ATT');
    }
    return "";
  },
  
  close: function () {
    if (_console.window && _console.open) {
      _console.sendMessage('DET');
      if (_console.target == '_blank') {_console.window.close()}
    }
    _console.window = null;
    _console.open = 0;
  },
  
  /*************************************************************************/

  /*
   *  For Firefox3 single-origin policy for local files
   */
  listen: function () {
    if (!window.postMessage || !window.addEventListener) return;
    if (window.opera || navigator.userAgent.match(/Safari/)) return;
    window.addEventListener("message",_console.receiveMessage,false);
    _console.listening = 1;
  },
  
  sendMessage: function (type,message,w) {
    if (w == null) {w = _console.window}; if (w == null) return;
    if (message == null) {message = ''}
    type = type.substr(0,3);
//    alert("["+(window.name||"window")+" send] "+type+":"+message); // debug
    if (_console.listening) {
      while (type.length < 3) {type += " "}
      w.postMessage('JSC3:'+type+":"+String(message),"*");
    } else {
      try {w._console.dispatch(type,message,window)} catch (err) {}
    }
  },
  
  receiveMessage: function (event) {
    var domain = event.origin.replace(/^file:\/\//,'');
    var ddomain = document.domain.replace(/^file:\/\//,'');
    if (domain == null || domain == "" || domain == "null") {domain = "localhost"}
    if (ddomain == null || ddomain == "" || ddomain == "null") {ddomain = "localhost"}
    if (domain != ddomain || event.data.substr(0,5) != 'JSC3:') return;
    var type = event.data.substr(5,3).replace(/ /g,'');
    var message = event.data.substr(9);
    _console.dispatch(type,message,event.source);
  },
  
  dispatch: function(type,message,source) {
//    alert("["+(window.name||"window")+" receive] "+type+":"+message); // debug
    if (_console.window == null) {_console.window = window.open("",_console.target)}
    if (_console.commands[type]) {(_console.commands[type])(message,source)}
  },

  /*
   *  The commands that can be dispatched
   */
  commands: {
    CMD: function (message,source) {
      if (source != _console.window || !_console.open) return;
      var result = _console.run(message);
      _console.sendMessage(result[0],result[1]);
    },

    OPN: function (message,source) {
      _console.open = 1;
      _console.sendMessage('TTL',document.title);
      _console.sendMessage('BUF',_console.buffer.join("\n"));
      _console.buffer = [];
    },

    ATT: function (message,source) {
      if (message != _console.target) {
        _console.target = message;
        _console.window = window.open("",_console.target);
      }
      _console.open = 1;
      attach();
    },
    
    DET: function (message,source) {
      _console.open = 0;
    },
    
    CLS: function (message,source) {
      _console.window = null;
      _console.open = 0;
    }
  },
  
  /*************************************************************************/

  /*
   *  Get the root directory for this script (so we can load the html file)
   */
  Root: function () {
    var script = document.getElementsByTagName('SCRIPT');
    var src = script[script.length-1].getAttribute('SRC');
    if (src.match('(^|/|\\\\)console.js$')) {return src.replace(/console.js$/,'')}
    return "";
  },
  
  Close: function () {_console.close()},
  
  Init: function () {
    this.root = this.Root();
    debug = this.debug;
    attach = this.attach;
    if (window.addEventListener) {window.addEventListener("unload",this.Close,false)}
    else if (window.attachEvent) {window.attachEvent("onunload",this.Close)}
    else {window.onunload = this.Close}
    this.listen();
    document.write('<SCRIPT SRC="'+_console.root+'show.js"></SCRIPT>');
  }
  
  /*************************************************************************/

}

_console.Init();
