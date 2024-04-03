# Open Access Policy Data Dedeuplication 
Independent project completed through my role as a Digital Scholarship Assistant in the Center for Digital Scholarship, IUPUI University Library. 

**Fall 2023-Spring 2024 Center for Digital Scholarship, IUPUI Univeristy Library**  
**Author:** Teryn Morgan  
**Programming Language:** R version 4.3.1

## Description
The University Library conducts an annual review system to compile IUPUI faculty written publications and upload them to IUPUI ScholarWorks in accordance with the Open Access Policy (OAP). This OAP workflow depends on accurate faculty self-reporting to identify eligible works for metadata extraction. Due to this dependency, ScholarWorks is not capturing all works affiliated with IUPUI faculty authors.  

This project aimed to search large literature databases (Clarivate, Elsevier, Lens, Academic Analytics) to extract works authored by IUPUI faculty in 2021-2022 and deduplicated these works against those that have already been retrieved through the annual review system. 

## Steps of Development
1. Compile and preprocess and files from the DMAI CrossRef Export: [documentation](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/DMAI%20CrossRef%20Export)
2. Extract affiliated works from IUPUI faculty within 2021-2022 from large literature databases
- [Academic Analytics](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/Academic%20Analytics)
- [Lens](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/Lens)
- [Scopus](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/Scopus)
- [Web of Science](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/Web%20of%20Science)
3. Deduplication with DMAI after CrossRef Lookup to identify records missed during the archival process: [documentation](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/DMAI%20Deduplication)
4. Further deduplication with IUPUI's Open Access Policy (OAP) metadata collection from 1981-2024: [documentation](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/OAP%20Deduplication)
5. Venn Analysis to visualize records shared between database results and DMAI/OAP collection tabularly and within venn diagrams: [documentation](https://github.com/terynmorgan/open-access-policy-workflow/tree/main/Venn%20Analysis)

## Required Files and Dependencies
Contained within each development step's documentation 
