# Principal-Component-Analysis

This is a summary of MATLAB tools I developed to facilitate PCA analysis

---Mahalanobis-Distance and getCovMatrices----
Main (Mahalanobis-Distance):  
This is a tool to determine if there is a statistical difference between two subgroups in a PC1-PC2 coordinates system  
It follows the routine demonstrated in https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4523310/  
It includes the calculation of Mahalanobis Distance followed by F-test statistics  
The program is designed for 2 variants (herein PC1 and PC2) and 2 subgroups (for example treatment and control group)  
Input here is an Excel Table with following format  
Columns: VAR1_group1 - VAR2_group1 - VAR1-group2 - VAR2_group2  
         (2nd col)     (3. col)      (4. col)      (5. col)  
         herein VAR1 = PC1  
                VAR2 = PC2  
User input: change in the code of MahalanobisDistance (main routine) the name of the sheet and insert number of groups (it's 2 as default, I recommend to leave that)  
Output: DW = Mahalanobis Distance  
        Tsqr = two sample Tsquared   
        F = F-Value  
        
 Function getCovMatrices is called to calculate the pooled between-group covariance matrix (according to https://blogs.sas.com/content/iml/2020/07/01/pooled-covariance-between-group.html)  
 
