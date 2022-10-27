# sample data for schooldb
#
# this needs to be a python file because inserting data into most tables in schooldb requires foreign key references,
# so functions such as get_nations_id, get_states_id, get_*_id are to generate nested SQL SELECT statements, in order
# to generate the sample data, just-a-bit more comfortably than copy-pasting in a text editor manually.
#
# the alternative would have been to predict the foreign key values, and lots of copy/pasting SQL statements in
# the text editor to manually create the filler.sql file...
#
# run as such in modern shell to generate the filler script, from the source directory:
# $ (cat init.sql && python filler-generation.py) | mysql -u root -p
#
# TODO separate all the *_template definitions from the function definitions to ease the reading, but only after the
# column names/NOT-NULL's are no longer changing
#

import sys
from filler_generation_data import *

print('USE `schooldb`')
print('BEGIN;')
print('')
print(generate_nations(nations_template))
print(generate_states(states_template))
print(generate_cityzip_pairs(cityzip_pairs_template))
print(generate_addresses(addresses_template))
print(generate_institutions(institutions_template))
print(generate_semesters(semesters_template))
print(generate_persons(persons_template))
print(generate_students(students_template))
print(generate_instructors(instructors_template))
print(generate_employees(employees_template))
print(generate_instructor_logins(instructor_logins_template))
print(generate_student_logins(student_logins_template))
print(generate_employee_logins(employee_logins_template))
print(generate_departments(departments_template))
print(generate_courses(courses_template))
print(generate_courses_prerequisites(courses_prerequisites_template))
print(generate_tracks(tracks_template))
print(generate_tracks_prerequisites(tracks_prerequisites_template))
print(generate_locations(locations_template))
print(generate_schedules(schedules_template))
print(generate_tasks(tasks_template))
print(generate_courses_tasks(courses_tasks_template))
print(generate_enrollments(enrollments_template))
print(generate_grades(grades_template))
print(generate_services(services_template))
print('')
print('COMMIT;')

