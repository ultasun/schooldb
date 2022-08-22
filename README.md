# School DB
#### *Bottega's Full Stack Development* homework

The author put a lot of thought into the architecture for this database schema which could be used by an educational institution with students from all over the world. Grades, professors, schedules, and nearly anything else the author was able to think of at the time ought to be covered by this schema.

If you find a missing concept, open an issue! This is the most complicated *SQL* schema the author has written to date.

If you'd like to run the project, please follow the instructions below:
 - Clone the repository to your machine
 - Inspect first, then execute `scripts/build.sh` and `scripts/install.sh`
   - **This will drop and instantiate one schema titled** *schooldb*, and populate with demo data
 - Inspect and run the five .sql files in bottega-tasks (`bottega-tasks/01.sql`, et al.) against the *schooldb* schema

Also, the entire SQL content can be seen by viewing `initialize.sql` in the root directory.

# Homework?

This was a homework assignment completed during the *Bottega Full Stack Development* certificate. View the `running-on-my-machine.txt` and `bottega-tasks/` directory.  The author earned a perfect score.

# Python

A *Python* script generates `initialize.sql`, see the `src/` directory.

# MySQL

The intended DBMS for this is *MySQL*.

# Credits

The author is the sole contributor to this work. See the `LICENSE` in the root directory for copyright information.

Thanks for reading!