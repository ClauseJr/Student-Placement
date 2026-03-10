# Student Placement End-to-End Analysis

## Executive Summary

### Overview Findings

This project demonstrates end-to-end data analysis of student placement outcomes, integrating academic performance, technical skills, communication ability, and interview readiness into a unified analytical model. Using Power BI and DAX, key placement metrics including placement rate, skill impact, readiness score, and placement risk were calculated to evaluate employability patterns. Cohort segmentation and readiness modeling were applied to identify job-ready students and high-risk groups. The resulting dashboards provide actionable insights into how technical competencies, communication skills, and interview preparation influence overall placement success.

The interactive Power BI dashboard enables us to:
  -  Analyze the impact of academic performance, communication skills, logical reasoning, interviews, projects, students aptitude, number of internships, and technical skills on placement success.
  -  Identify trends in placement rates, placement risks and the number of students placed.
  -  Identifying the risk factors that are likely to contribute in placement readiness of students.
  -  Understand temporal mechanism the contributes to high student placement success.
  -  Develop an interactive dashboard suitable for anlysis of student's placement and risk in placement readiness.

### Data Sources

A synthetically generated student placement dataset created for data analytics and visualization practice, containing upto 100,000 records. The dataset simulates academic performance, technical skills, experience indicators, and placement outcomes to analyze factors influencing student employability.

---

## Tools Used
a. Excel

Excel was used as the initial data preparation tool to:
  -  Clean and standardize column formats (texts, numerical fields)
  -  Handle missing, duplicates and inconsistent values
  -  Validate data integrity before visualization

This step ensured the dataset was well structured and analysis-ready before ingestion into PostgreSQL for analysis.

b. SQL(PostgreSQL)

The data was intergrated into PostgreSQl for SQL analysis and data cleaning
  -  Data Collection, Cleaning and Transformation
  -  Trend Analysis
  -  Explanatory analysis, Descriptive analysis and Predictive preparation

c. Power BI

Within Power BI:
  -  Creation of custom columns and conditional columns for data segmentation and trend analysis.
  -  DAX measures were created for the following KPIs:
      -  Total Students, Total Students Placed, Total Students not Placed
      -  Placement Readiness
      -  Placement Rate
      -  Placement Risk

Slicers were implemented for dynamic analysis by Gender and Voluteer experience.
    
---
## Data Analysis

```sql
-- Compare placement rates between: 
	-- Students with high technical skills but weak communication
	-- Students with moderate technical skills but strong communication
	
WITH student_tech_soft_score AS (
	SELECT
		*,
		ROUND(
			(coding_skill_score 
			+ aptitude_score 
			+ logical_reasoning_score 
			+ mock_interview_score)::numeric / 4.0
		,2) AS TechSkills_Score
	FROM student_placement_data
)
SELECT 
	CASE
		WHEN TechSkills_Score >= 75 AND communication_skill_score < 60 THEN 'HighTech_WeakComm'
		WHEN TechSkills_Score >= 55 AND TechSkills_Score < 75 AND communication_skill_score >= 75 THEN 'ModerateTech_StrongComm'
	END AS student_cohort,
	
	COUNT(*) total_number_students,
	ROUND(
		COUNT(CASE WHEN placement_status = 'Placed' THEN 1 END) * 100.0 / COUNT(*)
	,2) placement_rate
FROM student_tech_soft_score
WHERE (TechSkills_Score >= 75 AND communication_skill_score < 60) OR
	(TechSkills_Score >= 55 AND TechSkills_Score < 75 AND communication_skill_score >= 75)
GROUP BY student_cohort
ORDER BY placement_rate DESC

-- Students with very high technical skills but weak communication have slightly higher placement success 
	-- than students with moderate technical skills but strong communication, though the difference is marginal.
```
```sql
-- Identify students with CGPA ≥ 8.5 who were not placed and analyze their technical and soft skill weaknesses.

WITH student_tech_soft_score AS (
	SELECT
		*,
		ROUND(
			(coding_skill_score 
			+ aptitude_score 
			+ logical_reasoning_score 
			+ mock_interview_score)::numeric / 4.0
		,2) AS TechSkills_Score
	FROM student_placement_data
)
SELECT
	CASE
		WHEN TechSkills_Score < 60 AND communication_skill_score < 60 THEN 'Weak_tech_comm_skills'
		WHEN TechSkills_Score < 60 THEN 'Weak_tech_skills'
		WHEN communication_skill_score < 60 THEN 'Weak_comm_skills'
		ELSE 'Balanced'
	END skills_segmentation,
	COUNT(*) total_number_students,
	ROUND(AVG(TechSkills_Score)::numeric,2) avg_tech_skills_Score,
	ROUND(AVG(communication_skill_score)::numeric,2) avg_comm_skill_score
	
FROM student_tech_soft_score
WHERE cgpa >= 8.5 AND placement_status = 'Not Placed'
GROUP BY skills_segmentation
ORDER BY total_number_students DESC;

-- Total high-CGPA but not placed = 14,904 students
	-- a. Weak_tech_comm_skills (69% of group)
		-- Tech avg = 42.12
		-- Comm avg = 30.00
	-- b. Weak_tech_skills (28%)
		-- Tech avg = 37.54 (very low)
		-- Comm avg = 78.46 (strong)
	-- c. Weak_comm_skills (2.6%)
		-- Tech avg = 62.75
		-- Comm avg = 16.51
	-- d. Balanced (4 students)
		-- Tech = 61.85
		-- Comm = 76.23

```

---
## Project Dashboards

###  1. Overview Dashboard

This dashboard provides a high-level summary of the student's placement rates overview.

Key KPIs:
  -  Number of Students
  -  Students Placed
  -  Placement Rate

Analytical Insights:
  -  Higher placement rates of 73.07% was recorded among students with advaced coding skills, i.e Advaced -> Proficient -> Intermediate -> Beginner
  -  It was recorded that students with high aptitude capacities had higher placement rates compared to students with low aptitude capacity.
  -  Higher placement rates of 59.10% was recorded for studets with strong logical reasoning.
  -  The Probability of studets with higher and outstanding CGPA to be placed was high at 42.42%, since performance of a student determines the rate of placement.
  -  The overal number of students placed was 40,000 from the total number of students, and this significance was as a result of academic performance, technical skills difference, communication skills etc, that were key at determining students to be placed.
    
 This dashboard functions as an executive summary, offering quick insight for students placed, placement success and placement rates.
 
<img width="632" height="370" alt="Overview Page" src="https://github.com/user-attachments/assets/d7eb7584-90ee-400c-8621-6e2d7953fb13" />

###  2. Skills Impact Dashboard

The Skills Impact Dashboard focuses on demonstrating how different skills set such as communication skills impacts students placement rates.

Key KPIs:
  -  Number of Students
  -  Students Placed
  -  Placement Rate

Key Insights:
  -  Students with higher technical skills and stronger communication skills were highly placed, below is the summary of technical and communication skills distribution:
     -	High technical skills and strong communication skills 60.21%
     -	Balanced technical skills and communication skills 47.97%
     -	High technical skills and weak communication skills 32.73%
  -  Students with advanced coding skills were highly placed at a rate of 73.07% compared to students with average coding skills and beginners.
  -  Placement rate was directly propotional to the number of students not placed by coding skills. This is evident as the rate of coding skills increases to advanced levels, the rate of students with the same skills drop and thus more students are not placed.
  -  Students with Outstanding and Excellent academic performance were highly placed because of their intellectual capacities.
  -  Higher placement rates of students with higher aptitude capacities and higher mock interview scores, were highly placed as a result of their highest abilities in different capacities.


<img width="633" height="371" alt="Skill Impact Page" src="https://github.com/user-attachments/assets/c4350904-ee54-4d47-8292-002df9569732" />

###  3. Risk Readiness Dashboard

The Risk Readiness Dashboard focuses on the analysis of students placement risks and placement readiness. When the rate of placement is low, suddenly the student has a high risk of not being placed.

Key KPIs:
  -  Number of Students
  -  Placement Rate
  -  Placement Readiness
  -  Placement Risk
    
Key Insights:
-	students with poor communication skills, beginners in coding, very weak logical reasoning, lower scores in mock interviews, less project and poor academic performances had a high risk of placement.
-	Students with higher placement risk had a low placement rate hence not placed.

<img width="632" height="371" alt="Risk Readiness Page" src="https://github.com/user-attachments/assets/3df4111d-6a8b-4921-bfc4-91e1be505bac" />

---

## Key Areas of Analysis

### 1.	Placement Rate Analysis

-	Impact of students technical and communication analysis on placement rates
-	Placement rate analysis on students academic performance
-	Analysis of the number of projects done and mock interview performance on placement rates

### 2.	Demographic Analysis
-	Students academic performance had a high imapct on students placement, Outstanding and Excellent students were highly placed. 
-	Technical and Communication skills had high impact on placement of students, high technical skills and strong communication skills were highly placed.
-	Sleeping hours, class attendance and studying hours had a less impact on placement.

<img width="192" height="134" alt="coding skills" src="https://github.com/user-attachments/assets/feeb0295-68f1-4338-a07b-82403aed2a90" />
<img width="257" height="140" alt="cgpa" src="https://github.com/user-attachments/assets/68fdd743-a426-44df-8a4d-844a7e9bc54e" />
<img width="230" height="136" alt="reasoning" src="https://github.com/user-attachments/assets/f6922afd-a577-420a-949c-efd6f9cfbd88" />


### 3.	 Technical Skills and Communication Skills segments
-	Students technical and communication skills had a high impact on placement as follows:
     -	High technical skills and strong communication skills 60.21%
     -	Balanced technical skills and communication skills 47.97%
     -	High technical skills and weak communication skills 32.73%
-	Some students with strong communication skills and low technical skills and those with high technical skills and weak communication skills had chances of being placed
-	Students with Less skills and weak communication skills had a high risk of placement
  
### 4.	Skills impact on Students Placement
-	Students with high number of experience (Number of Internships) were highly placed because of their experience in the industry
-	Students with higher aptitude capacities were preferably placed because of their higher abilities that could impact the industry.
-	Students with strong reasoning abilities were highly preferred and hence their high placement
-	Students with highest mock interview scores were highly placed since they had knowledge of what is needed in the industry.

### 5.	Placement Risk and Placement Readiness
-	There was high risk of students with poor communication skills not being placed, since the higher the placement risks the lower the placement rates                                                
	-	This highlights that placement rates are not detrmined by poor communication skills, rather strong communication skills
-	Students with beginner coding skills had higher riks of placement, since coding skills has a high impact on students placement
-	Students with low interview scores (Not Ready) had high placement risks, since interview score has a high impact on students placement

---

## Recommendations

### 1. Strengthen Technical Skill Development
Students with stronger technical abilities, particularly higher coding and logical reasoning scores, show better placement outcomes. Colleges should introduce more hands-on programming labs, coding challenges, and technical workshops to improve these competencies and better prepare students for recruitment assessments.

### 2. Increase Access to Internship Opportunities  
Internships provide valuable real-world experience and significantly improve employability. Institutions should collaborate with industry partners to create more internship programs, ensuring that students gain practical exposure before graduation.
   
### 3. Enhance Interview Preparation Programs
Mock interview performance is an important indicator of placement success. Universities should conduct regular mock interview sessions, resume-building workshops, and career counseling programs to help students improve their confidence and interview performance.

### 4. Encourage Skill-Based Certifications and Projects  
Students with more certifications and practical projects demonstrate stronger technical and professional readiness. Educational institutions should encourage students to complete industry-recognized certifications and participate in project-based learning to strengthen their portfolios.

### 5. Focus on Holistic Skill Development
Placement success is influenced by a combination of academic performance, technical skills, communication ability, and practical experience. Colleges should adopt a holistic training approach that integrates technical training, soft skill development, leadership activities, and extracurricular engagement to better prepare students for the job market.

---
##	Limitations

This analysis has several limitations that should be acknowledged when interpreting the results:

-	The dataset used in the project is synthetically generated, meaning it was created for analytical practice rather than collected from real institutional records; therefore, the relationships observed may not fully reflect real-world placement dynamics.
-	The dataset primarily focuses on academic performance, technical skills, and internship experience, while other influential factors such as industry demand, networking opportunities, and organizational hiring practices are not captured.
-	Complex attributes like communication ability and technical competence are represented using simplified numerical scores, which may not entirely reflect the multidimensional nature of these skills in real recruitment processes.


---

##  Conclusion

This project analyzed the key factors influencing student employability by examining academic performance, technical skills, soft skills, and practical experience using SQL-based data analysis and interactive dashboards in Microsoft Power BI. The analysis revealed that student placement outcomes are driven by a combination of factors rather than a single attribute. Technical competencies such as coding ability, logical reasoning, and aptitude scores emerged as strong indicators of placement readiness, while practical experience gained through internships and projects further improves employability by providing real-world exposure. Soft skills, particularly communication ability and performance in mock interviews, also play an important role in the recruitment process as they influence interview success and professional presentation. Although academic performance, represented by CGPA, contributes to placement potential, the findings indicate that strong academic results alone do not guarantee employment without complementary technical and professional skills. Overall, the project demonstrates that successful placements are associated with a balanced combination of academic strength, technical proficiency, practical experience, and effective communication, highlighting the importance of holistic skill development in preparing students for the job market.

---

## References
1.	SQL for Data Engineering [Data with Baraa](https://www.youtube.com/watch?v=SSKVgrwhzus)
2.	Data Analytics with [Chandoo](https://www.youtube.com/results?search_query=chandoo)
3.	[HackerRank](https://www.hackerrank.com/dashboard)


