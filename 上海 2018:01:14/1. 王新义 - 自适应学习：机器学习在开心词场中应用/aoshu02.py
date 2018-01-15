# -*- coding: utf-8 -*-
"""
Created on Sat Sep 30 09:52:19 2017

@author: Administrator
"""
#%%
for i in range(1,9):
    for j in range(1,9):
        for k in range(1,9):
            for m in range(1,9):
                ss=str(i)+str(j)+str(k)+str(m)+str((i*100+j*10+k)*m)
                if len(ss)==8 and len(set(list(ss)))==8 and  '0' not in ss and '9' not in ss :
                    print(ss[0:3]+'*'+ss[3]+'='+ss[4:])


#%%


from itertools import permutations
print([''.join(x[:3])+'*'+''.join(x[3])+'='+''.join(x[4:]) for x in list(permutations('12345678', 8)) if int(''.join(x[:3]))*int(x[3])==int(''.join(x[4:]))])

for x in list(permutations('12345678',8)):
    if int(''.join(x[:3]))*int(x[3])==int(''.join(x[4:])):
        print(x)
        print(''.join(x[:3])+'*'+''.join(x[3])+'-'+''.join(x[4:])+'='+str(int(''.join(x[:3]))*int(x[3])-int(''.join(x[4:]))))

#%%

def lose(x):
    return abs((x[0]*100+x[1]*10+x[2])*x[3]-(x[4]*1000+x[5]*100+x[6]*10+x[7]))

def  swap(x,i,j):
    xx=x.copy()
    tmp=xx[i]
    xx[i]=xx[j]
    xx[j]=tmp
    return xx

    

def gd(x):
    min_lose_value=lose(x)
    ori_lose_value=min_lose_value
    min_lose_array=x.copy()
    for i in range(0,7):
        for j in range(i+1,8):
            x_tmp=swap(x,i,j)
            lose_v_tmp=lose(x_tmp)
            if lose_v_tmp <= min_lose_value :
                min_lose_value=lose_v_tmp
                min_lose_array=x_tmp.copy()
    #print(min_lose_array)
    #print(lose(min_lose_array))
    return min_lose_array,ori_lose_value-min_lose_value
                
    

def train(x):
    xx,grad_value=gd(x)
    #print(xx)
    #print(grad_value)
    while lose(xx)>0 and grad_value>0:
        xx,grad_value=gd(xx)
        print(grad_value,xx,lose(xx))
    return xx

#import sys
#sys.getrecursionlimit()
#sys.setrecursionlimit(5000)

x=[1,2,3,4,5,6,7,8]
ss=train(x)
ss
x


#%%
import random
def lose(x):   #lose function
    return abs((int(x[0])*100+int(x[1])*10+int(x[2]))*int(x[3])-(int(x[4])*1000+int(x[5])*100+int(x[6])*10+int(x[7])))

def  swap(x,i,j):  #
    xx=x.copy()
    tmp=xx[i]
    xx[i]=xx[j]
    xx[j]=tmp
    return xx

def sgd(x):  #stochastic gradient descent
    data_dict={}
    for i in range(0,7):
        for j in range(i+1,8):
            x_tmp=swap(x,i,j)
            lose_v_tmp=lose(x_tmp)
            data_dict[''.join(x_tmp)]=lose_v_tmp
    dd=sorted(data_dict.items(),key=lambda item:item[1])
    #print(dd[1][0])
    return list(dd[random.randint(0, 10)][0])
 
def train(x):
    while lose(x)>0 :
        x=sgd(x)
        print(x,'lose value:',lose(x))
    return x

x=['1','2','3','4','5','6','7','8']
ss=train(x)
print()
print(ss)


#%%
import scipy.optimize
import copy


def de_obj_fun(x): #The objective function to be minimized
    data = list(copy.deepcopy(x))
    data.sort()
    idx = list(x)
    count = list(map(lambda t: str(idx.index(t) + 1), data))
    #print(data)
    #print(count)
    a = int("".join(count[:3]))
    b = int("".join(count[3]))
    c = int("".join(count[4:]))
    #print(abs(a*b-c))
    return abs(a*b - c)
    
def result_decode(x):
    data = list(copy.deepcopy(x))
    data.sort()
    idx = list(x)
    count = list(map(lambda t: str(idx.index(t) + 1), data))
    a = int("".join(count[:3]))
    b = int("".join(count[3]))
    c = int("".join(count[4:]))
    return a,b,c

#差分进化算法 (Differential Evolution) #best1exp  #best1bin #best2exp\rand1exp
for i in range(1,10):
    a=scipy.optimize.differential_evolution(de_obj_fun, [(-1, 1)]*8,strategy='randtobest1exp',tol=0.0) 
    print(result_decode(a['x']))


#%%
import scipy.optimize
import copy
import random
import math

def de_obj_fun(x): #The objective function to be minimized
    data = list(copy.deepcopy(x))
    data=[math.exp(x) for x in data]
    data_1=list(map(str,map(int,data)))
    print(data_1)
    if len(set(data_1))<8:
        return  random.randint(2000, 3000)
    #print(type(data_1))
    a = int("".join(data_1[:3]))
    b = int("".join(data_1[3]))
    c = int("".join(data_1[4:]))
    print(abs(a*b-c))
    return abs(a*b - c)
    
def result_decode(x):
    data = list(copy.deepcopy(x))
    data=[math.exp(x) for x in data]
    data_1=list(map(str,map(int,data)))
    print(data_1)
    #print(type(data_1))
    a = int("".join(data_1[:3]))
    b = int("".join(data_1[3]))
    c = int("".join(data_1[4:]))
    return a,b,c

#差分进化算法 (Differential Evolution)
#best1exp
#best1bin
#best2exp\rand1exp
#for i in range(1,10):
a=scipy.optimize.differential_evolution(de_obj_fun, [(0.0, 2.14)]*8,strategy='best1bin') 
print(result_decode(a['x']))

import math
math.log(8.5)
math.exp(2.14)
