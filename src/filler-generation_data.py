nations_template = [
    ('United States', 'US'),
    ('Mexico', 'MX'),
    ('Canada','CA'),
    ('United Kingdom', 'UK'),
    ('Japan', 'JP'),
    ('Peru', 'PE')
]
states_template = [
    ('Pennsylvania', 'PA', get_nations_id('US')),
    ('New Jersey', 'NJ', get_nations_id('US')),
    ('Florida', 'FL', get_nations_id('US')),
    ('New York', 'NY', get_nations_id('US')),
    ('Texas', 'TX', get_nations_id('US'))
]
cityzip_pairs_template = [
    ('Indianland', '18088', get_states_id('PA')),
    ('Berlinsville', '18088', get_states_id('PA')),
    ('Nesquehoning', '18240', get_states_id('PA')),
    ('Bloomsburg', '17815', get_states_id('PA')),
    ('Tampa', '33609', get_states_id('FL')),
    ('Tampa', '33611', get_states_id('FL')),
    ('Houston', '77001', get_states_id('TX'))
]
addresses_template = [
    ('1111 Lehigh Dr', get_cityzip_pairs_id('Indianland', '18088'), 'false'),
    ('1111 Lake Dr', get_cityzip_pairs_id('Nesquehoning', '18240'), 'false'),
    ('1111 University Dr', get_cityzip_pairs_id('Bloomsburg', '17815'), 'false'),
    ('3828 W Platt St', get_cityzip_pairs_id('Tampa', '33609'), 'false'),
    ('5217 Puritan Ave', get_cityzip_pairs_id('Tampa', '33611'), 'false'),
    ('1111 Nowhere St', get_cityzip_pairs_id('Houston', '77001'), 'false'),
    ('1111 Somewhere Pl', get_cityzip_pairs_id('Berlinsville', '18088'), 'false')
]
institutions_template = [
    ('Bloomsburg University Of Pennsylvania', get_states_id('PA'), 'BU', get_addresses_id('1111 University Dr'), 'https://bloomu.edu', 'true', 'true', 'false')
]
semesters_template = [
    ('Fall 2021', '2021-09-01 08:00:00', '2021-12-23 21:00:00', get_institutions_id('BU'))
]
persons_template = [
    ('James Capozzoli', get_nations_id('US'), get_states_id('PA'), 'manykwh@localhost', get_addresses_id('1111 Lehigh Dr'), 'false'),
    ('Mike Mol', get_nations_id('US'), get_states_id('PA'), 'mikethemol@localhost', get_addresses_id('1111 Lake Dr'), 'false'),
    ('Cindy Carma', get_nations_id('US'), get_states_id('PA'), 'cindycarma@localhost', get_addresses_id('1111 University Dr'), 'false'),
    ('Adam Appletosh', get_nations_id('US'), get_states_id('FL'), 'adamappletosh@localhost', get_addresses_id('3828 W Platt St'), 'false'),
    ('Casey Bro', get_nations_id('US'), get_states_id('TX'), 'caseybro@localhost', get_addresses_id('1111 Nowhere St'), 'false'),
    ('Margret Mi-yetta', get_nations_id('US'), get_states_id('PA'), 'margretmi@localhost', get_addresses_id('1111 University Dr'), 'false'),
    ('Cassidy Clever', get_nations_id('US'), get_states_id('PA'), 'cash@localhost', get_addresses_id('1111 University Dr'), 'false'),
    ('Yennifer Yaboozle', get_nations_id('PE'), get_states_id('FL'), 'yenny@localhost', get_addresses_id('5217 Puritan Ave'), 'false'),
    ('Luis Rico', get_nations_id('US'), get_states_id('FL'), 'commonname@localhost', get_addresses_id('5217 Puritan Ave'), 'false'),
    ('Selina Sikorsky', get_nations_id('US'), get_states_id('NJ'), 'helicopter@bearingfailure.com', get_addresses_id('1111 Somewhere Pl'), 'true'),
    ('Diana Deerbourne', get_nations_id('US'), get_states_id('PA'), 'propolice@localhost', get_addresses_id('1111 University Dr'), 'false'),
    ('Amy Ante', get_nations_id('US'), get_states_id('PA'), 'drante@localhost', get_addresses_id('1111 University Dr'), 'false')]
students_template = [
    (get_persons_id('James Capozzoli'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Adam Appletosh'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Casey Bro'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Yennifer Yaboozle'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Luis Rico'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Selina Sikorsky'), get_institutions_id('BU'), 'true')
]
instructors_template = [
    (get_persons_id('Cindy Carma'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Cassidy Clever'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Margret Mi-yetta'), get_institutions_id('BU'), 'false'),
    (get_persons_id('Amy Ante'), get_institutions_id('BU'), 'false')
]
employees_template = [
    (get_persons_id('Mike Mol'), get_institutions_id('BU'), 'false')
]
instructor_logins_template = [
    (get_instructors_id('Cindy Carma', 'BU'), get_institutions_id('BU'), 'ccarma@bu.notreal', 'false'),
    (get_instructors_id('Cassidy Clever', 'BU'), get_institutions_id('BU'), 'cclever@bu.notreal', 'false'),
    (get_instructors_id('Margret Mi-yetta', 'BU'), get_institutions_id('BU'), 'miata@bu.notreal', 'false'),
    (get_instructors_id('Amy Ante', 'BU'), get_institutions_id('BU'), 'aante@bu.notreal', 'false')
]
student_logins_template = [
    (get_students_id('James Capozzoli', 'BU'), get_institutions_id('BU'), 'jac00178@huskies', 'false'),
    (get_students_id('Adam Appletosh', 'BU'), get_institutions_id('BU'), 'aaa01234@huskies', 'false'),
    (get_students_id('Casey Bro', 'BU'), get_institutions_id('BU'), 'ccc01234@huskies', 'false'),
    (get_students_id('Yennifer Yaboozle', 'BU'), get_institutions_id('BU'), 'yyy01234@huskies', 'false'),
    (get_students_id('Luis Rico', 'BU'), get_institutions_id('BU'), 'lr_01234@huskies', 'false'),
    (get_students_id('Selina Sikorsky', 'BU'), get_institutions_id('BU'), 'sss01234@huskies', 'true')
]
employee_logins_template = [
    (get_employees_id('Mike Mol', 'BU'), get_institutions_id('BU'), 'mikemol@somewhe.re', 'false')
]
departments_template = [
    ('HRM', get_institutions_id('BU'), get_instructors_id('Cindy Carma', 'BU'), 'false'),
    ('COMPSCI', get_institutions_id('BU'), get_instructors_id('Cassidy Clever', 'BU'), 'false'),
    ('CHEM', get_institutions_id('BU'), get_instructors_id('Margret Mi-yetta', 'BU'), 'false')
]
courses_template = [
    ('Customer Service 1', '3.0', get_departments_id('HRM', 'BU'), '101', 'true', 'true', 'false'),
    ('Customer Service 2', '3.0', get_departments_id('HRM', 'BU'), '201', 'true', 'true', 'false'),
    ('Introduction to Java', '3.0',  get_departments_id('COMPSCI', 'BU'), '101', 'true', 'true', 'false'),
    ('Database Design I', '3.0', get_departments_id('COMPSCI', 'BU'), '110', 'true', 'true', 'false'),
    ('Chemistry Lab for Sciences I', '4.0', get_departments_id('CHEM', 'BU'), '110', 'true', 'false', 'false')
]
courses_prerequisites_template = [
    (get_courses_id('HRM', 'BU', '201'), get_courses_id('HRM', 'BU', '101'))
]
tracks_template = [
    ('HRM TRACK', get_institutions_id('BU'), 'true', 'true', 'false'),
    ('Computer Science Bachelors', get_institutions_id('BU'), 'true', 'true', 'false')
]
tracks_prerequisites_template = [
    (get_tracks_id('HRM TRACK', 'BU'), get_courses_id('HRM', 'BU', '201')),
    (get_tracks_id('Computer Science Bachelors', 'BU'), get_courses_id('COMPSCI', 'BU', '101')),
    (get_tracks_id('Computer Science Bachelors', 'BU'), get_courses_id('COMPSCI', 'BU', '110'))
]
course_equivalencies_template = [] # no
locations_template = [
    ('Building A', 'false')
]
schedules_template = [ # notice how all these 3 credit hour classes have 330 minutes scheduled a week for them...there's a relationship there
    ('0800', '0950', '-M-W-F-', '2021-09-01 08:00:00', '2021-12-22 09:50:00', 'false', get_semesters_id('Fall 2021', get_institutions_id('BU'))),
    ('1000', '1150', '-M-W-F-', '2021-09-01 10:00:00', '2021-12-22 11:50:00', 'false', get_semesters_id('Fall 2021', get_institutions_id('BU'))),
    ('1300', '1450', '-M-W-F-', '2021-09-01 13:00:00', '2021-12-22 14:50:00', 'false', get_semesters_id('Fall 2021', get_institutions_id('BU'))),
    ('1500', '1650', '-M-W-F-', '2021-09-01 15:00:00', '2021-12-22 16:50:00', 'false', get_semesters_id('Fall 2021', get_institutions_id('BU'))),
    ('0800', '1045', '--T-T--', '2021-09-02 08:00:00', '2021-12-23 10:45:00', 'false', get_semesters_id('Fall 2021', get_institutions_id('BU')))
]
tasks_template = [
    ('HRM 101 QUIZ 1', '100', 'true'),
    ('HRM 201 QUIZ 1', '100', 'true'),
    ('COMPSCI 101 QUIZ 1', '100', 'true')
]
courses_tasks_template = [
    (get_tasks_id('HRM 101 QUIZ 1'), get_courses_id('HRM', 'BU', '101'), '1.0'),
    (get_tasks_id('HRM 201 QUIZ 1'), get_courses_id('HRM', 'BU', '101'), '1.0'),
    (get_tasks_id('COMPSCI 101 QUIZ 1'), get_courses_id('HRM', 'BU', '101'), '1.0')
]
enrollments_template = [
    (get_students_id('James Capozzoli', 'BU'), get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '0950'), get_courses_id('HRM', 'BU', '101'), 'false'),
    (get_students_id('Yennifer Yaboozle', 'BU'),  get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '0950'), get_courses_id('HRM', 'BU', '101'), 'false'),
    (get_students_id('Adam Appletosh', 'BU'), get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '0950'), get_courses_id('HRM', 'BU', '101'), 'false'),
    (get_students_id('Casey Bro', 'BU'), get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '0950'), get_courses_id('HRM', 'BU', '101'), 'false'),
    (get_students_id('Luis Rico', 'BU'), get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '0950'), get_courses_id('HRM', 'BU', '101'), 'false'),
    (get_students_id('Selina Sikorsky', 'BU'), get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '0950'), get_courses_id('HRM', 'BU', '101'), 'false'),
    
    (get_students_id('James Capozzoli', 'BU'), get_instructors_id('Cassidy Clever', 'BU'), get_schedules_id('1000', '1150'), get_courses_id('COMPSCI', 'BU', '101'), 'false'),
    (get_students_id('Yennifer Yaboozle', 'BU'),  get_instructors_id('Cassidy Clever', 'BU'), get_schedules_id('1000', '1150'), get_courses_id('COMPSCI', 'BU', '101'), 'false'),
    (get_students_id('Adam Appletosh', 'BU'), get_instructors_id('Cassidy Clever', 'BU'), get_schedules_id('1000', '1150'), get_courses_id('COMPSCI', 'BU', '101'), 'false'),
    (get_students_id('Casey Bro', 'BU'), get_instructors_id('Cassidy Clever', 'BU'), get_schedules_id('1000', '1150'), get_courses_id('COMPSCI', 'BU', '101'), 'false'),
    (get_students_id('Luis Rico', 'BU'), get_instructors_id('Cassidy Clever', 'BU'), get_schedules_id('1000', '1150'), get_courses_id('COMPSCI', 'BU', '101'), 'false'),
    (get_students_id('Selina Sikorsky', 'BU'), get_instructors_id('Cassidy Clever', 'BU'), get_schedules_id('1000', '1150'), get_courses_id('COMPSCI', 'BU', '101'), 'false'),

    (get_students_id('James Capozzoli', 'BU'), get_instructors_id('Cindy Carma', 'BU'), get_schedules_id('0800', '1045'), get_courses_id('HRM', 'BU', '201'), 'true') # only audits are allowed to take classes without satisfied prereqs? need this for task 5

]
grades_template = [
    (get_enrollments_id('James Capozzoli', 'BU', '0800', '0950'), '100.00', get_tasks_id('HRM 101 QUIZ 1'), '2021-09-05 08:00:00', '2021-09-08 21:00:00'),
    (get_enrollments_id('Yennifer Yaboozle', 'BU', '0800', '0950'), '100.00', get_tasks_id('HRM 101 QUIZ 1'), '2021-09-05 08:00:00', '2021-09-08 21:00:00'),
    (get_enrollments_id('Adam Appletosh', 'BU', '0800', '0950'), '100.00', get_tasks_id('HRM 101 QUIZ 1'), '2021-09-05 08:00:00', '2021-09-08 21:00:00'),
    (get_enrollments_id('Casey Bro', 'BU', '0800', '0950'), '100.00', get_tasks_id('HRM 101 QUIZ 1'), '2021-09-05 08:00:00', '2021-09-08 21:00:00'),
    (get_enrollments_id('Luis Rico', 'BU', '0800', '0950'), '100.00', get_tasks_id('HRM 101 QUIZ 1'), '2021-09-05 08:00:00', '2021-09-08 21:00:00'),
    (get_enrollments_id('Selina Sikorsky', 'BU', '0800', '0950'), '100.00', get_tasks_id('HRM 101 QUIZ 1'), '2021-09-05 08:00:00', '2021-09-08 21:00:00'),
    
    (get_enrollments_id('James Capozzoli', 'BU', '1000', '1150'), '100.00', get_tasks_id('COMPSCI 101 QUIZ 1'), '2021-09-05 10:00:00', '2021-09-08 21:09:33'),
    (get_enrollments_id('Yennifer Yaboozle', 'BU', '1000', '1150'), '100.00', get_tasks_id('COMPSCI 101 QUIZ 1'), '2021-09-05 10:00:00', '2021-09-08 21:09:31'),
    (get_enrollments_id('Adam Appletosh', 'BU', '1000', '1150'), '100.00', get_tasks_id('COMPSCI 101 QUIZ 1'), '2021-09-05 10:00:00', '2021-09-08 21:09:30'),
    (get_enrollments_id('Casey Bro', 'BU', '1000', '1150'), '100.00', get_tasks_id('COMPSCI 101 QUIZ 1'), '2021-09-05 10:00:00', '2021-09-08 21:09:32'),
    (get_enrollments_id('Luis Rico', 'BU', '1000', '1150'), '100.00', get_tasks_id('COMPSCI 101 QUIZ 1'), '2021-09-05 10:00:00', '2021-09-08 21:09:38'),
    (get_enrollments_id('Selina Sikorsky', 'BU', '1000', '1150'), '100.00', get_tasks_id('COMPSCI 101 QUIZ 1'), '2021-09-05 10:00:00', '2021-09-08 21:09:35')
]
services_template = []
