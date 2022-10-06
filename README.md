# School DB
*School DB* is a [*MySQL*](https://www.mysql.com/) database schema which could be used by a [higher educational institution](https://en.wikipedia.org/wiki/Educational_institution#Further_and_higher_education) with students from all over the world. Grades, professors, schedules, class sections, and nearly anything else required by such an institution, ought to be covered by this schema.

### Evolution
If you find a missing *business* *concept*, open an issue! This is the most complicated *SQL* schema the author has written to date.  Improving this schema to cover an overlooked use case could be a constructive hobby -- but please do not open the issue if it would cause this system to deviate away from the *business needs* of an educational institution.

### Homework
This was a homework assignment completed during the *Bottega Full Stack Development* certificate. View the [`running-on-my-machine.txt`](https://github.com/ultasun/schooldb/blob/master/running-on-my-machine.txt) file, and the `bottega-tasks/` directory, for a demonstration.  

This submission achieved a perfect score, on the basis that, all five `bottega-tasks/` returned the correct records.

The author decided to challenge themselves by designing the database to be as elaborate as possible.  This was not an assignment criteria.

### Python
A *Python* script generates `initialize.sql`, see the `src/` directory.

### MySQL
The intended [*DBMS*](https://en.wikipedia.org/wiki/Database#Database_management_system) for this schema is *MySQL*.

# Installation
### Dependencies 
*Python 3*, *BASH*, and *MySQL* are required to follow the *Installation Procedure*.

The procedure may be completed on *Windows* without *BASH* -- the *BASH* scripts are not complicated, and may easily be adapted to work in a *Windows* environment.

The *BASH* scripts are just a couple lines each, it is reasonable to manually enter the commands into a shell.

### MySQL Configuration
The script `scripts/install.sh` expects to use the `root` user, and will prompt you for the password -- adjust accordingly, as needed.

## Installation Procedure
If you'd like to run the project, please follow the instructions below:
1. Clone the repository to your machine,
2. Inspect first, then execute `scripts/build.sh` and `scripts/install.sh`,
- **This will drop and instantiate one database schema titled** *schooldb*, and populate with demo data,
3. Inspect and run the five `.sql` files in bottega-tasks (`bottega-tasks/01.sql`, et al.) against the *schooldb* schema,
- Compare this to the values in the [`running-on-my-machine.txt`](https://github.com/ultasun/schooldb/blob/master/running-on-my-machine.txt) file.
 - The results should be identical, because the test data used to generate `running-on-my-machine.txt` is the same test data currently in this repository.

Also, the entire generated *SQL* content can be found in `initialize.sql` in the root directory -- remember, this file is generated by the *Python* script.

# Credits
The author is the sole contributor to this work. See the `LICENSE` in the root directory for copyright information.

Thanks for reading!
