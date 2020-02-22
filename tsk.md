% TSK(1)

# NAME

tsk - manage tasks

# DESCRIPTION

_Tsk_ is a task management system whose aim is to provide a familiar interface (similar to 'mail').

## Fields

Each task consists of the following fields:

### ID

A 5 character ID of the task. This is assigned upon creation and is based on the hash of the creation date

### Assignee

Who is the task assigned to as entered by the user

### Task name

The name of the task as entered by the user

### Priority

Priority of the task as entered by the user. Tasks will be sorted alphabetically, therefore it is recommended to put a number in front of them. For example: '1 High', '2 Medium' or '3 Low'.

### Due date

Due date for the task. Format is not enforced, although the _YYMMDD_ format is recommended.

### Created

Creation date of the task in the _YYMMDDHHMMSS_ format. This is assigned automatically upon task creation.

## Commands

There is two modes of entering **tsk** commands. First is by running **tsk** without arguments, which will open the interactive mode. This a loop where the user is prompted from a command, it is evaluated and the user gets prompted again until they quit. The second one is by passing the arguments directly to **tsk** from the shell (e.g. **tsk a**), which will instruct **tsk** to carry out that action and exit.

### Adding tasks

By entering the 'a' command a series of questions or prompted to the user asking for the user input task fields. When all the questions are answered the task is added to the task list.

### Printing tasks

By entering the **p** command the user can print the list of tasks. Not inputting any command and pressing the return key also prints the list of tasks. The tasks will be shown in 6 columns as per the task fields.

### Doing tasks

By entering the **d** command followed by the task ID, tasks can be marked as done. This effectively means that the tasks will be removed from the task list and will be appended to the list of done tasks.

### Manual edit

For debugging purposes or in case some field was entered wrong, rather than having to delete it and add the task from scratch, the **e** command opens an editor (the 'EDITOR' environmental variable if it is available, otherwise it tries to open 'vi') to be able to manually edit the tasks.

### Quick add

To be able to pipe tasks to 'tsk', the **i** option exists. stdin from **tsk i** will create a new task with all the parameters as default execpt for TASK NAME which will be filled with the received stdin.

### Exiting

The command 'q' exits tsk.

# EXAMPLES

An usual tsk workflow starts with running 'tsk':

    $ tsk

and creating a task:

    ? add
    Assignee [-]: Alice
    Task name: Buy some eggs
    Priority [-]: 3 Low
    Due date [888888]: 100603

the new task can be printed:

    ?
    ID     ASSIGNEE  TASK NAME      PRIORITY  DUE     CREATED
    03857  Alice     Buy some eggs  3 Low     100603  200222001442

after the task is done, it can be marked as done:

    ? d 03857
    [Sat 02 Jun 14:15:02 GMT 2011]: 03857,Alice,Buy some eggs,3 Low,100603,200602101442

when it is marked as done it will print the task as it is save on the done tasks list.

If the task list is printed again now it is going to show empty:

    ?
    ID  ASSIGNEE  TASK NAME  PRIORITY  DUE  CREATED

After everything is finished, tsk can be closed to return back to the shell prompt:

    ? q
    $
