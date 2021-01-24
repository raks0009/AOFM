# SamaTulyata Tool
Prototype of CPN-based Equivalence checker


1. equivchecker-master.zip: Contains ecplise plugin.(https://github.com/santonus/equivchecker.git)

2. Equivalence-checker-master.zip: Contains first version of tool (https://github.com/soumyadipcsis/Equivalence-checker.git)

*********************************************************************************************************************************
1. FSMDEQX -- the FSMD equivalence checker (both path extension based FSMDEQX-PE and value propagation FSMDEQX-VP based) 
   with which comparison has been made
***********************************************************************************************************************************
2. DCPEQX -- 

(a) Manual-- DCPEQX module + hand constructed CPN models for both sequential and parallel examples 
   
(b) Automated-- the DCPEQX module + a front end for taking FSMD models and having them transformed to CPN mdoels     
   through an automated model constructor.

(Accepted in Acta Informatica)
************************************************************************************************************************************
3. SCPEQX -- 

(a) Manual -- SCPEQX module + hand constructed CPN models for both sequential and parallel examples 
   
(b) Automated -- the SCPEQX module + a front end for taking FSMD models and having them transformed to CPN mdoels 
   through an automated model constructor.

(Published in ATVA 2017 as Tool paper and Under review in Acta Informatica)
************************************************************************************************************************************
4. RunThesisExamples: There is a shell script which helps to run all examples which are presented in the paper
************************************************************************************************************************************
5. output: This directory contails the verification results for all the examples which are presented in the paper
************************************************************************************************************************************
6. thesisKulwant.pdf -- M. Tech. dissertation of Kulwant Singh on Automated model constructor (used here).
************************************************************************************************************************************

Steps in experimentation: Refer to the README files in items ...

For Running all examples use the command "./RunThesisExamples.sh" 
If "SYNTAX ERROR" comes, please dont worry and go ahead.

For measuring time you can use get_cpu_time(), gettimeofday() and settimeofday().
All three provisions are available in the tool. In the thesis our time measurement is carried out using get_cpu_time().

The older version is also available in 
https://cse.iitkgp.ac.in/~chitta/pubs/rep/thesisBench.zip

If you face any problem, please contact us using the contact information given below. 

email: soumyadip.bandyopadhyay@hpi.de 
 
email: soumyadip.bandyopadhyay@gmail.com

Skype: soumyadip12
