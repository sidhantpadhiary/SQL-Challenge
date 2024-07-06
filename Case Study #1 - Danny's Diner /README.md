# [Case study no. 1 - Danny's Diner](https://8weeksqlchallenge.com/case-study-1/)
<p align="center">
<img src="/Images/1.png" width=40% height=40%>

* ### [Introduction](#introduction)
* ### [Problem Statement](#problem-statement-1)
* ### [Entity Relationship Diagram](#entity-relationship-diagram-1)
* ### Example Datasets
    * Table 1: sales
    * Table 2: menu
    * Table 3: members
* ### Case Study Questions
* ### Bonus Questions
---
## Introduction

> Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

> Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.
<br />

---
## Problem Statement

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. He plans on using these insights to help him decide whether he should expand the existing customer loyalty program.

<br />

---
## Entity Relationship Diagram
<p align="left">
<img src="/Images/2.png" width=50% height=50%>


## Example Datasets
# Table 1: sales

> The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.

| customer_id   |	order_date    | product_id
| A	          | 2021-01-01	  | 1
| A	          | 2021-01-01	  | 2
| A	          | 2021-01-07	  | 2
| A	          | 2021-01-10	  | 3
| A	          | 2021-01-11	  | 3
| A	          | 2021-01-11	  | 3
| B	          | 2021-01-01	  | 2
| B	          | 2021-01-02	  | 2
| B	          | 2021-01-04	  | 1
| B	          | 2021-01-11	  | 1
| B	          | 2021-01-16	  | 3
| B	          | 2021-02-01	  | 3
| C	          | 2021-01-01	  | 3
| C	          | 2021-01-01	  | 3
| C	          | 2021-01-07	  | 3
