# Operating Systems - Term Project
## Sofia Harmon & Ryan Scolforo

### Features Implemented:
- Built-In commands:
   - setenv variable word, printenv, unsetenv variable, cd, alias name word, unalias name, alias, bye, infinite loop alias-expansion detection
- Non Built-In commands:
   - ls, pwd, wc, sort, page, nm, cat, cp, mv, ping, echo
- Executable files
- Redirecting I/O with Non-built-in Commands
- Environment Variable Expansion
- Alias Expansion
- Tilde Expansion

### Features Not Implemented:
- Using Pipes with Non-built-in Commands
- File redirection for builtin commands
- Running Non-built-in Commands in Background
- Using both Pipes and I/O Redirection, combined, with Non-built-in Commands
- Wildcard Matching
- File Name Completion


#### Sofia: 
I worked on the file redirection for non-builtin commands, but was unable to get it working for builtin commands. This includes redirecting the output to a specified file, reading input from a specified file, appending output to a specified file, and redirecting the command’s standard errors to a specified file or to the standard output file.
I was able to implement the environment variable expansion for any case except for in quotes.
I also completed the tilde expansion, which can take in a user name and replace it with the user’s home directory or can expand to the current home directory if no user name is specified.
I built the command table in order to store non-builtin command parameters, and created a function which handles command execution for non-builtins and executable files. This function also handles all file redirection. The functionality also includes scanning each directory in the PATH variable in order to verify the existence of the command. This allows for commands to be used for directories such as “/bin”.
I handled scanning the input and executing the corresponding builtin commands for removing aliases and printing aliases. 

#### Ryan:
I developed the functionality for the setenv, unsetenv, and printenv functions. For the printenv function I looped through the variable table which stored the environment variables passed in. With the setenv and unsetenv functions, the parser is able to set and unset environment variables, passed in through the command line. 
I tried to implement the piping functionality. I wanted to make a piping function, to which two arguments could be passed in and allow the first token word to pipe its output into the second token. This would be called recursively to handle multi pipe commands. I was unsuccessful in getting the lexer to connect with the parser and allow for the correct commands to go into the piping function. 
I attempted to build the functionality to run non-built in commands in the background. I tried to get the lexer to return a token called BACKGROUND when the command line encounters a &. This token would then change a value in the command table called backgroundVal, to represent that this process should happen in the background and thus the parent process in our executeCmd function does not wait for the child process to finish. Unfortunately, it did not work. 
I aimed to create the ability to handle wildcard matching, but was unsuccessful. I tried to make it recognize when a ? or * are passed in the command line. This word token would be passed in as a pattern, of which would be matched with a list of possible commands it could be. I was unable to get it to work though. 

##### Description: 
Once installed, our project creates a command interpreter much like the terminal on a personal computer. The shell uses lex and yacc(flex and bison) to parse command lines and execute the required commands. Essentially, a command line goes to the lexer, the lexer then breaks the line into individual tokens, these tokens go to the parser, where the parser determines what commands should be run. 

##### Design: 
We chose to design a command table that parses each segment of a non-builtin command and stores each part (i.e. command name, arguments, input/output files, etc) so when the program executes the command it has all of the command’s information available. Each command is parsed one word at a time and, depending on the format/value of the word, is stored and handled accordingly. The newline character signals the function for executing a command, which handles all file redirection and command executing.

##### Verification: 
Once running the program using make all and then “./main”, the command prompt will appear and will be ready to accept commands. Simple verification would entail feeding the prompt commands and verifying the output. There is also a sample program (tst.c) and its executable (./tst) in the project directory. This program takes in any amount of command line arguments and prints them, along with an error message. This can be used to verify the command line argument being used correctly and file I/O redirection. By changing the redirection of the standard error, you can also verify 2>file and 2>&1 work properly based on the destination of the error message that prints.
