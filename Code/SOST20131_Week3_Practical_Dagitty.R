# SOST20131 / SOST30031
# WEEK 3 PRACTICAL: CAUSAL DAGs WITH DAGITTY
#
# The focus is causal reasoning: confounders, mediators, colliders,
# backdoor paths, and adjustment sets.


# ============================================================
# SESSION AIMS
# ============================================================
# By the end of this practical, you should be able to:
#
# 1. Represent causal assumptions using a directed acyclic graph (DAG).
# 2. Distinguish confounders, mediators, and colliders.
# 3. Identify backdoor paths between an exposure and an outcome.
# 4. Use Dagitty to identify sufficient adjustment sets.
# 5. Explain why adjusting for every available variable can be a mistake.


# ============================================================
# 0. SET-UP
# ============================================================
# We will use the R package "dagitty".
#
# Install this package ONLY if you do not already have it:

install.packages("dagitty")
library(dagitty)

# You can also explore the same DAGs visually using the Dagitty web interface:
# https://dagitty.net/dags.html


# ============================================================
# RESEARCH QUESTION
# ============================================================
# We will use one substantive question throughout:
#
#   What is the TOTAL causal effect of education on earnings?
#
# Exposure: Education
# Outcome: Earnings
#
# IMPORTANT:
# A DAG does not prove that the arrows are correct.
# It represents the causal assumptions we are making.


# ============================================================
# 1. A SIMPLE DAG: CONFOUNDING
# ============================================================
# Suppose parental socioeconomic position (Parental_SES) affects both:
#   - a person's education
#   - their later earnings
#
# Complete the DAG below by adding the missing arrows.
#
# Expected causal assumptions:
# Parental_SES -> Education
# Parental_SES -> Earnings
# Education -> Earnings

dag1 <- dagitty('dag {
  Education [exposure]
  Earnings [outcome]

  Parental_SES -> Education
  Parental_SES -> Earnings
  Education -> Earnings

}')

plot(dag1)


# QUESTIONS
#
# Q1. What is the causal path from Education to Earnings?
# Education -> Earnings

# Q2. Is there a backdoor path between Education and Earnings?
#     If yes, write it down.
# Earnings <- Parental_SES -> Education

# Q3. Which variable is the confounder?
# Parental_SES

# Q4. Before asking Dagitty, which variable do you think we should adjust for?
# Parental_SES, because it is a confounder

# Now ask Dagitty:
adjustmentSets(dag1)
#
# Q5. Does Dagitty agree with your answer?
# Yes

# Optional: list the paths between Education and Earnings.
paths(dag1, from = "Education", to = "Earnings")

# ============================================================
# 2. ADDING A MEDIATOR
# ============================================================
# Now suppose education affects occupation, which then affects earnings.
#
# Add Occupation as a mediator:
#
#   Education -> Occupation -> Earnings
#
# Keep the relationships from DAG 1.

dag2 <- dagitty('dag {
  Education [exposure]
  Earnings [outcome]

  Parental_SES -> Education
  Parental_SES -> Earnings
  Education -> Earnings
  Education -> Occupation -> Earnings

}')

plot(dag2)


# QUESTIONS
#
# Q6. What role does Occupation play in this DAG?
# Mediator

# Q7. We want the TOTAL effect of Education on Earnings.
#     Should we adjust for Occupation? Why or why not?
# No. Occupation is a mediator.
# Adjusting for a mediator blocks part of the causal effect of Education on Earnings,
# so you would no longer estimate the total effect.

# Q8. Ask Dagitty for a sufficient adjustment set.
adjustmentSets(dag2)

# Q9. Is Occupation included in the adjustment set?
# No

# Q10. What part of the causal effect would we remove if we controlled
#      for Occupation?
# The indirect effect of Education that operates through Occupation.
# would only estimate the direct effect of Education on Earnings

# ============================================================
# 3. ADDING A COLLIDER
# ============================================================
# Now consider employment status.
#
# Suppose:
#   Education -> Employment
#   Health -> Employment
#   Health -> Earnings
#
# Employment is therefore a common effect of Education and Health.
#
# Complete the DAG.

dag3 <- dagitty('dag {
  Education [exposure]
  Earnings [outcome]

  Parental_SES -> Education
  Parental_SES -> Earnings

  Education -> Earnings
  Education -> Occupation
  Occupation -> Earnings
  Education -> Employment
  Health -> Employment
  Health -> Earnings

}')

plot(dag3)


# QUESTIONS
#
# Q11. What role does Employment play on the path:
#
#      Education -> Employment <- Health -> Earnings
# Collider

# Q12. Is this path open or closed if we do NOT condition on Employment?
# Closed. Collider paths are naturally closed without conditioning.

# Q13. What can happen if we control for Employment?
# Conditioning on a collider opens the collider path
# Creates a spurious association between Education and Health
# can bias  causal estimate for the effect of Education on Earnings (collider bias)

# Q14. Imagine that our dataset contains earnings only for people who are
#      currently employed. Why could this create a problem?
# Sample selection bias
# conditioning on Employment (the collider) by restricting our sample to employed people only
# opens the collider path and introduces spurious correlation between Education and Health
# biases the estimated effect of Education on Earnings

# Now ask Dagitty for an adjustment set for the TOTAL effect:
adjustmentSets(dag3)

# Q15. Does Dagitty tell us to adjust for:
#      (a) Parental_SES?
#      (b) Occupation?
#      (c) Employment?
# Parental_SES

# Explain each answer using the terms confounder, mediator, and collider.
# Parental_SES is a confounder (common cause of Education and Earnings) on the backdoor path
# We need to adjust for it to close this backdoor path.

# Occupation is a mediator on a causal pathway from Education to Earnings.
# Controlling it would block part of the total causal effect we want.

# Employment is a collider. We must NOT adjust for it; 
# conditioning on colliders opens a previously closed path and creates bias.

# ============================================================
# 4. EXTENSION: MODIFY THE DAG
# ============================================================
# Choose ONE of the following:
#
# A. Add Age as a common cause of Education and Earnings.
# B. Add Ability as a common cause of Education and Earnings
