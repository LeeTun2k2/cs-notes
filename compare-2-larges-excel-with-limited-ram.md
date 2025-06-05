---
title: "Compare Two Large Excel Files with Limited RAM"
date: 2025-06-05
tags: ["big data", "excel", "external sort", "stream processing", "comparison"]
---


## Overview

I am currently working with an data set which is stored in excel. It is just well until the excel file is to large and I can not load totally this file into RAM so I can not process next step. 

In this post, I’ll show you how to **compare 2 large datasets efficiently** using a technique based on **external merge sort** and **streaming comparison**.

## Problem
I have 2 Excel files which have same model, each file has ~1000GB. The problem is that I need to find the differences between records, but I just have only 16GB RAM available.

## Solution Overview

1. **Sort both files externally**  
2. **Stream through both sorted files and compare row-by-row**

---

## Step 1: External Sort

We can't load everything into memory, so we use a disk-based sorting approach.

### 1.1 Chunk and Hash
- Split each file into 1GB chunks
- There is no unique ID exists, so I create a hash per row for comparison. Each hash was created from implement all on each column.

### 1.2 Sort Each Chunk
- Load each chunk into memory
- Sort it and save it as a temporary file
To save the CPU resource, I open an parallel process and limit to 8 threads running at the same time to prevent from overhead memory.

### 1.3 Merge Sorted Chunks
Use a **priority queue (min-heap)** to do a k-way merge:

```text
For each chunk file:
    Open a stream and read the first row
    Push it into a min-heap with source reference

While the heap is not empty:
    Pop the smallest row
    Write it to a final sorted file
    Read the next row from the same source file, push it back to the heap
```

## Step 2: Stream & Compare

Now we have two sorted files. Let's compare them efficiently:

```text
Open a stream for each sorted file
Read the first row from both → a, b

While both streams have data:
    If a == b → they match → advance both
    If a < b  → a is unique to file A → advance a
    If a > b  → b is unique to file B → advance b

Write differences to output
```

This is similar to a merge step in merge sort, but with comparison logic.

## Pros and Cons

### Pros

- RAM usage is minimal

- Scales to TB-sized files

- Simple logic, easy to debug

- Can be parallelized or distributed if needed

### Cons

- Use a large of disk to store temperature files.

- Trade off the memory usage to CPU times.


## Sumarize

With careful chunking, sorting, and streaming, even massive Excel files can be compared on a modest machine. No need for big clusters or expensive cloud tools.

This approach works not just for Excel but for any structured text data: CSV, JSONL, etc.

