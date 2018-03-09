#!/usr/bin/python3

def generate_bi_lt_sum(n: int, start:int=1):
    i = start
    while i < n-i:
        yield i, n-i
        i += 1

def generate_bi_le_sum(n: int, start:int=1):
    i = start
    while i <= n-i:
        yield i, n-i
        i += 1

def generate_tri_lt_sum(n: int):
    a = 1
    while a < n//2:
        for b, c in generate_bi_lt_sum(n-a, a):
            yield a,b,c
        a += 1

def generate_tri_le_sum(n: int):
    a = 1
    while a < n//2:
        for b, c in generate_bi_le_sum(n-a, a):
            yield a,b,c
        a += 1

for a,b,c in generate_tri_lt_sum(1000):
    if a*a + b*b == c*c:
        print(a*b*c)
