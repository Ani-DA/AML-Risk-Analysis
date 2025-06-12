# AML Risk Analysis


![Untitled design](https://github.com/user-attachments/assets/be838396-bc0f-4c10-8df2-35aa7333c81e)




## 1. Project Overview 

This AML/CFT data analysis project investigates 30,000 simulated transaction records to identify suspicious patterns and laundering behaviors. The project focuses on corridor analysis, payment methods, laundering techniques, and temporal trends. Feature engineering was used to build a comprehensive risk scoring model that classifies transactions into high, medium, and low-risk categories. Key insights are presented through an interactive Power BI dashboard to aid proactive risk management and regulatory compliance.


## 2. Data Overview 

The dataset consists of 30,000 simulated transaction records, each capturing key details relevant to Anti-Money Laundering (AML) analysis. Each row here records a transaction which inncludes fields such as transaction timestamp, transaction date, sender and receiver account details, transaction amount, payment and received currencies, bank locations, payment type, laundering flag, and laundering method. 

Transaction Dataset Columns

* **`Time`**: Captures the exact transaction time. Useful for identifying suspicious intraday patterns and transaction bursts.

* **`Date`**: Records the transaction date. Enables time-series and periodicity analysis, such as month-end or seasonal laundering trends.

* **`Sender_account`**: Unique ID of the sender’s account. Critical for tracing transaction flows and identifying account-level laundering behaviors.

* **`Receiver_account`**: Unique ID of the receiver’s account. Helps in mapping recipient networks and detecting common laundering endpoints.

* **`Amount_in_GBP`**: Standardized transaction amount in GBP. Facilitates uniform value comparison across multi-currency transactions.

* **`Payment_currency`**: Indicates the currency used by the sender. Useful for cross-currency risk analysis and exchange pattern detection.

* **`Received_currency`**: Shows the currency received by the recipient. Enables detection of currency mismatches often used in laundering schemes.

* **`Sender_bank_location`**: Country of the sender’s bank. Important for identifying high-risk jurisdictions and cross-border movement patterns.

* **`Receiver_bank_location`**: Country of the receiver’s bank. Helps in mapping laundering corridors and destination hotspots.

  
![db1](https://github.com/user-attachments/assets/e52dcc60-2c89-4801-b215-daa81faca599)

* **`Payment_type`**: Specifies the transaction method (e.g., Credit Card, Wire Transfer). Key for identifying high-risk payment channels.

* **`Is_laundering`**: Binary flag indicating whether a transaction is classified as laundering (1) or legitimate (0). Serves as the target variable for risk and fraud analysis.

* **`Laundering_type`**: Describes the laundering technique applied (e.g., Structuring, Fan Out). Supports typology-based risk segmentation.




## 3. Analysis and Insights

This project follows an exploratory data analysis (EDA) approach, aiming to uncover patterns and risks associated with money laundering without being driven by predefined business questions. The analysis is broken down into four key focus areas:
1. Corridor analysis
2. Payment type analysis
3. Laundering type analysis
4. Time period analysis.
Then using feature engineering using SQL, some features and flags are created for better monitor the risk.
All analysis are done in SQL Server and visualization in Power BI.

Starting with the KPIs, total txns, no of laundered txns, %, amount etc.
Analysis done in sql and then visualised in Power BI.



![pb1](https://github.com/user-attachments/assets/adb7a9ae-c217-4d9b-9ea8-a0e21794b1f5)


**1. Corridor Analysis**

The investigation of transaction flows between countries revealed that certain cross-border corridors are frequently exploited for laundering activities. The UK → UAE corridor emerged as the most prominent, contributing significantly to both the volume and total amount of laundered funds. 



The UK -> UAE Corridor has the highest numbers of  laundering transactions, 15% of overall txns and 27% of the laundered txns. This Corridor is also the top in the total laundered amount, 15 % of the overall txns and 21 % of laundered txns.


Interestingly, while sorting the txns based upon the average amount for laundering txns , USA -> Panama, Cayman Islands -> and USA -> Singapore topped the chart  with around 13K GBP on average Txn and the UK -> UAE stood at the last with around 9K GBP on an average.



GBP - > Dirham has the highest no of Amount and no of Txns both among the overall txns and the laundered txns. I amounts to 14.7% of laundered txns and 15.6% of overall txns.  This seems to positively correlate to the Corridor wise laundered txns figures. 

![cav](https://github.com/user-attachments/assets/4dfcfbd1-7f4a-4533-b5b9-1a92614d60b5)



**2. Payment Type Analysis**

Contrary to common assumptions, Credit Card transactions accounted for the highest laundered amounts and transaction counts, surpassing traditional methods like Cash Deposits. 

Laundering txns using Credit card has the highest volume ,i.e, 33 M and in numbers. It accounts to 30% of the total laundered txns.  Whereas cash deposits which thought to be the popular mode of money laundering, have a total volume of 26 M, comprises 12% of the total laundered transactions. 

![ptv1](https://github.com/user-attachments/assets/323a733e-a62e-436c-842d-98c78ed59581)


In the historical analysis across payment types also we see the similar trend

![ptv2](https://github.com/user-attachments/assets/f4289c87-0134-4aab-9c57-c46e49ec2ece)


**3. Laundering Type Analysis**

The most prevalent laundering method identified was Structuring (Smurfing), which made up the largest share of laundered transactions and amounts. Interestingly, the Fan Out method exhibited the highest average transaction amount, suggesting that even lower-frequency laundering types can carry significant financial risk.


The most amount was laundered by 'Structuring', that is 33% of laundered txns and it amounts to around 44 million, whereas surprisingly "Cross Border Movement" is just 17%. Also if we look at the average amount laundered during txns, it is by 'Fan Out'



![ltv2](https://github.com/user-attachments/assets/5bdeff01-8913-4a90-8c33-5fb4a1ed63b9)


**4. Time Period Analysis**

Temporal analysis uncovered spikes in laundering activity:


No of Laundering Txns display a sudden shoot up on 28th day of the month, which is nearly 5% above the average txns during the month, possibly indicates the later days of the month, whereas the legit txns maintain a steady flow throughout the month. Similarly laundering txns display a sudden 5% spike during 13 hrs to 17 hrs during the day, whereas the legit txns do not any particular trend.

Year 2023 see a steady downward trend in the laundering activity, nearly 3.5%  than the previous year. Further investigation needed to point possible reason.



![tpv](https://github.com/user-attachments/assets/ae64e1c2-3bd9-4728-9892-9fd7a8b04604)



**Risk Scoring and Feature Engineering**

To enhance detection capabilities, a risk scoring model was developed using SQL feature engineering. This model calculates a total risk score for each transaction based on multiple factors:

`Cross-Border Score:` Penalizes cross-country transactions with higher risk weights.

`Amount Score:` Assigns higher scores to larger transactions.

`Currency Score:` Flags transactions involving currency conversions.

`Payment Type Score:` Prioritizes riskier payment modes like cash deposits and cross-border payments.

`Geography Score:` Accounts for known high-risk jurisdictions like UAE, Panama, and Cayman Islands.

`Temporal Score:` Flags repeated transactions between the same accounts within the same day.

`Amount Pattern Score:` Detects possible structuring by flagging transactions just below typical reporting thresholds.

Using these features, transactions were categorized into Low, Medium, and High-Risk Tiers.

Additionally, a `Priority Review Flag` was applied to transactions that met specific high-risk criteria, enabling compliance teams to focus on urgent cases.

The risk scoring model was deliberately applied to non-laundering transactions to simulate a real-world scenario where the model proactively identifies potentially suspicious activities not yet confirmed as laundering.




Using conditional formatting flagging high risk transactions for easier identification.


![rav](https://github.com/user-attachments/assets/16abc55f-365d-4329-b32e-159b5caa2c5b)



## 4. Code Analysis 
The entire analysis has been done in SQL Server Management Studio. The sql file is attached in the repository. Here some code snippets for the analysis are attached.

**KPI Calculation**

![sql1](https://github.com/user-attachments/assets/c0ce9da6-1619-4520-a9ee-070240da8e39)



![sql2](https://github.com/user-attachments/assets/3de17b0c-f1d0-4ebb-86d2-822f57b412b6)


**Risk Exposure by Corridor :	Analysing Domestic and International Txns**



![sql3](https://github.com/user-attachments/assets/9c7ee13d-8439-4597-a803-ffbe0f28196f)



![sql4](https://github.com/user-attachments/assets/21703c56-b662-459c-847d-b80e3510d64a)



![sql5](https://github.com/user-attachments/assets/b58d7723-e62a-4c9c-8fdd-a5204dd82665)

**Transaction Type Red Flags : comparing Payment Types**

![sql6](https://github.com/user-attachments/assets/97a05de2-9c9e-4af1-a407-00624f6e4f29)

**Laundering type Analysis**

![sql7](https://github.com/user-attachments/assets/ace1aa8c-d50f-4d80-8383-311e5bdea302)


![sql8](https://github.com/user-attachments/assets/ea8575f9-2d7a-439b-a832-c913351f02c3)



**Time-Based Laundering Trend : Analysing Date and Hours when Laundering may be frequented**

![sql9](https://github.com/user-attachments/assets/3b52e07c-3f57-4502-a353-74f3652fc0ea)


![sql10](https://github.com/user-attachments/assets/c9a0add7-3a88-492d-9e79-1d1ff53e8486)



**A SQL View is created for implementing the risk features ,calculating the total risk scores and creating the risk flag.**


![sql11](https://github.com/user-attachments/assets/7a7ef4f4-92d4-4423-9f63-a30b9a13e0cb)


## 5. Recommendations

**Corridor Analysis suggests:**
Implement enhanced due diligence (EDD) and stricter monitoring controls specifically for transactions routed through the UK → UAE corridor. Consider introducing corridor-based risk scoring and targeted audits to detect patterns early. Also, collaborate with UAE counterparts to share intelligence and close regulatory gaps. 

**Recommendations based on Payment Type Analysis**

Consider developing specialized monitoring rules for digital payment methods, especially credit card cross-border transactions, which may be exploited for laundering due to their speed and relative anonymity. While cash deposits still pose risks, allocate additional resources to non-cash laundering vectors, reflecting evolving laundering tactics.

Additionally, conduct a root cause analysis to understand why credit cards are favored—whether it's due to gaps in controls, loopholes in digital onboarding, or specific institutions being targeted—and work with financial institutions to tighten controls.

**Recommendations based on Laundering Type Analysis**

Strengthen transaction monitoring systems to better detect structuring patterns, such as multiple small transactions that cumulatively exceed thresholds. Implement real-time alerting for aggregation patterns and encourage enhanced due diligence (EDD) for accounts showing signs of structuring, even when individual transactions fall below standard reporting limits.

Also, even though ‘Cross Border Movement’ appears lower in volume, continue close monitoring, as cross-border risks remain critical, especially when combined with other laundering methods.

For ‘Fan Out’, focus on high-value transaction monitoring, as these larger-value dispersals, though less frequent, may represent significant laundering risk. You might also consider network analysis to trace the broader pattern of fund distribution typical of Fan Out schemes.

**Recommendations based on Time Period Analysis**

Implement enhanced surveillance around month-end, especially from the 25th to 30th, to catch end-of-month laundering bursts. These could be linked to reporting period closures or attempts to balance books before audits. Introduce temporal pattern flags to raise alerts when abnormal spikes occur close to the month's end.

Tighten monitoring during these afternoon hours. This may coincide with overlap between global banking hours (e.g., UK-UAE or USA-Panama corridors). Build time-of-day risk scoring into your models and consider focusing manual reviews on suspicious transactions in this time band.


**Some additional recommendations**
**Proactively Review Medium-Risk Transactions:**
Medium-risk transactions comprise a significant proportion of flagged activity. A sampling or risk-based review process for medium-risk transactions can help balance resource allocation while still capturing emerging laundering patterns.

**Validate and Calibrate the Scoring Model Regularly:**
The scoring weights used in this project are based on simulated rules. In a real-world scenario, these weights should be continuously validated against confirmed laundering cases and recalibrated to improve precision and reduce false positives.

**Automate Priority Review Queues:**
The priority review flag should feed directly into compliance workflows, enabling the rapid triage of transactions requiring immediate investigation, thus improving operational efficiency.
