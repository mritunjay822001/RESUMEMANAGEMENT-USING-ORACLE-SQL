—RESUME MANAGEMENT SYSTEM—————


-- Create the Candidates table
CREATE TABLE Candidates (
    candidate_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(20),
    address VARCHAR2(200),
    summary CLOB
);

-- Create the Work_Experience table
CREATE TABLE Work_Experience (
    experience_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_id NUMBER,
    company_name VARCHAR2(100) NOT NULL,
    job_title VARCHAR2(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    responsibilities CLOB,
    CONSTRAINT fk_work_candidate FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id)
);

-- Create the Education table
CREATE TABLE Education (
    education_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_id NUMBER,
    institution_name VARCHAR2(100) NOT NULL,
    degree VARCHAR2(100) NOT NULL,
    field_of_study VARCHAR2(100),
    graduation_date DATE,
    CONSTRAINT fk_education_candidate FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id)
);

-- Create the Skills table
CREATE TABLE Skills (
    skill_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skill_name VARCHAR2(50) UNIQUE NOT NULL
);

-- Create a junction table for Candidates and Skills (many-to-many relationship)
CREATE TABLE Candidate_Skills (
    candidate_id NUMBER,
    skill_id NUMBER,
    CONSTRAINT pk_candidate_skills PRIMARY KEY (candidate_id, skill_id),
    CONSTRAINT fk_cs_candidate FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    CONSTRAINT fk_cs_skill FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
);

-- Create the Projects table
CREATE TABLE Projects (
    project_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    candidate_id NUMBER,
    project_name VARCHAR2(100) NOT NULL,
    description CLOB,
    start_date DATE,
    end_date DATE,
    CONSTRAINT fk_project_candidate FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id)
);

-- Insert sample data
INSERT INTO Candidates (first_name, last_name, email, phone, address, summary)
VALUES ('John', 'Doe', 'john.doe@email.com', '123-456-7890', '123 Main St, Anytown, USA', 'Experienced software developer with a passion for creating efficient and scalable applications.');

INSERT INTO Candidates (first_name, last_name, email, phone, address, summary)
VALUES ('Jane', 'Smith', 'jane.smith@email.com', '987-654-3210', '456 Elm St, Othertown, USA', 'Creative graphic designer with a keen eye for detail and a strong portfolio of brand identity projects.');

INSERT INTO Work_Experience (candidate_id, company_name, job_title, start_date, end_date, responsibilities)
VALUES (1, 'Tech Solutions Inc.', 'Senior Developer', TO_DATE('2018-03-01', 'YYYY-MM-DD'), TO_DATE('2023-06-30', 'YYYY-MM-DD'), 'Led a team of 5 developers, implemented CI/CD pipeline, reduced deployment time by 50%');

INSERT INTO Work_Experience (candidate_id, company_name, job_title, start_date, end_date, responsibilities)
VALUES (1, 'Software Innovations LLC', 'Junior Developer', TO_DATE('2015-07-01', 'YYYY-MM-DD'), TO_DATE('2018-02-28', 'YYYY-MM-DD'), 'Developed and maintained web applications, collaborated with cross-functional teams');

INSERT INTO Work_Experience (candidate_id, company_name, job_title, start_date, end_date, responsibilities)
VALUES (2, 'Creative Designs Co.', 'Lead Designer', TO_DATE('2019-01-15', 'YYYY-MM-DD'), NULL, 'Manage brand identity projects for Fortune 500 companies, mentor junior designers');

INSERT INTO Education (candidate_id, institution_name, degree, field_of_study, graduation_date)
VALUES (1, 'University of Technology', 'Bachelor of Science', 'Computer Science', TO_DATE('2015-05-15', 'YYYY-MM-DD'));

INSERT INTO Education (candidate_id, institution_name, degree, field_of_study, graduation_date)
VALUES (2, 'Design Institute', 'Bachelor of Fine Arts', 'Graphic Design', TO_DATE('2014-06-30', 'YYYY-MM-DD'));

INSERT INTO Skills (skill_name) VALUES ('JavaScript');
INSERT INTO Skills (skill_name) VALUES ('Python');
INSERT INTO Skills (skill_name) VALUES ('SQL');
INSERT INTO Skills (skill_name) VALUES ('React');
INSERT INTO Skills (skill_name) VALUES ('Node.js');
INSERT INTO Skills (skill_name) VALUES ('Adobe Creative Suite');
INSERT INTO Skills (skill_name) VALUES ('UI/UX Design');

INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (1, 1);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (1, 2);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (1, 3);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (1, 4);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (1, 5);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (2, 3);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (2, 6);
INSERT INTO Candidate_Skills (candidate_id, skill_id) VALUES (2, 7);

INSERT INTO Projects (candidate_id, project_name, description, start_date, end_date)
VALUES (1, 'E-commerce Platform', 'Developed a full-stack e-commerce platform using React and Node.js', TO_DATE('2020-03-01', 'YYYY-MM-DD'), TO_DATE('2020-08-31', 'YYYY-MM-DD'));

INSERT INTO Projects (candidate_id, project_name, description, start_date, end_date)
VALUES (2, 'Brand Redesign', 'Led a comprehensive brand redesign for a major retail chain', TO_DATE('2021-02-15', 'YYYY-MM-DD'), TO_DATE('2021-07-30', 'YYYY-MM-DD'));

-- Example queries

-- 1. Get a candidate's full resume
SELECT 
    c.first_name, 
    c.last_name, 
    c.email, 
    c.phone, 
    c.summary,
    LISTAGG(DISTINCT s.skill_name, ', ') WITHIN GROUP (ORDER BY s.skill_name) as skills,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'company' VALUE we.company_name,
            'title' VALUE we.job_title,
            'start_date' VALUE TO_CHAR(we.start_date, 'YYYY-MM-DD'),
            'end_date' VALUE TO_CHAR(we.end_date, 'YYYY-MM-DD'),
            'responsibilities' VALUE we.responsibilities
        )
    ) as work_experience,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'institution' VALUE e.institution_name,
            'degree' VALUE e.degree,
            'field' VALUE e.field_of_study,
            'graduation_date' VALUE TO_CHAR(e.graduation_date, 'YYYY-MM-DD')
        )
    ) as education,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'name' VALUE p.project_name,
            'description' VALUE p.description,
            'start_date' VALUE TO_CHAR(p.start_date, 'YYYY-MM-DD'),
            'end_date' VALUE TO_CHAR(p.end_date, 'YYYY-MM-DD')
        )
    ) as projects
FROM 
    Candidates c
LEFT JOIN Candidate_Skills cs ON c.candidate_id = cs.candidate_id
LEFT JOIN Skills s ON cs.skill_id = s.skill_id
LEFT JOIN Work_Experience we ON c.candidate_id = we.candidate_id
LEFT JOIN Education e ON c.candidate_id = e.candidate_id
LEFT JOIN Projects p ON c.candidate_id = p.candidate_id
WHERE 
    c.candidate_id = 1
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, c.email, c.phone, c.summary;

-- 2. Find candidates with specific skills
SELECT 
    c.first_name, 
    c.last_name, 
    c.email,
    LISTAGG(s.skill_name, ', ') WITHIN GROUP (ORDER BY s.skill_name) as matching_skills
FROM 
    Candidates c
JOIN Candidate_Skills cs ON c.candidate_id = cs.candidate_id
JOIN Skills s ON cs.skill_id = s.skill_id
WHERE 
    s.skill_name IN ('JavaScript', 'React', 'Node.js')
GROUP BY 
    c.candidate_id, c.first_name, c.last_name, c.email
HAVING 
    COUNT(DISTINCT s.skill_id) = 3;

-- 3. Get candidates with experience at a specific company
SELECT DISTINCT
    c.first_name, 
    c.last_name, 
    c.email,
    we.job_title,
    we.start_date,
    we.end_date
FROM 
    Candidates c
JOIN Work_Experience we ON c.candidate_id = we.candidate_id
WHERE 
    we.company_name = 'Tech Solutions Inc.';

-- 4. Find candidates with projects in a specific date range
SELECT 
    c.first_name, 
    c.last_name, 
    c.email,
    p.project_name,
    p.start_date,
    p.end_date
FROM 
    Candidates c
JOIN Projects p ON c.candidate_id = p.candidate_id
WHERE 
    p.start_date >= TO_DATE('2020-01-01', 'YYYY-MM-DD') AND 
    (p.end_date <= TO_DATE('2021-12-31', 'YYYY-MM-DD') OR p.end_date IS NULL);

-- 5. Get the most common skills across all candidates
SELECT 
    s.skill_name, 
    COUNT(cs.candidate_id) as skill_count
FROM 
    Skills s
JOIN Candidate_Skills cs ON s.skill_id = cs.skill_id
GROUP BY 
    s.skill_id, s.skill_name
ORDER BY 
    skill_count DESC
FETCH FIRST 5 ROWS ONLY;