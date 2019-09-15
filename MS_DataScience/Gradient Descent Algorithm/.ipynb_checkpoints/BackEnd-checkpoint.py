#!/usr/bin/env python
# coding: utf-8

import numpy as np
import pandas as pd

def gd_exact_step(Q, c, x, tolerance, N):
    
    #Defining the initial values
    k=1
    error = 100
    
    #Data frame to store each iteration data
    log = pd.DataFrame(columns = ['Iteration', 'Xk', 'Xk+1', 'Pk', 'Step Size', 'Error'])
    
    while (error > tolerance) & (k <= N):
        x_init = x
        gradient = (np.matmul(Q, x) + c)
        step = np.matmul(gradient.T, gradient) / np.matmul(np.matmul(gradient.T, Q), gradient)
        x = x - step*gradient
        error = np.linalg.norm(gradient)
        
        log_info = {
            'Iteration': k,
            'Xk': x_init,
            'Xk+1': x,
            'Pk': gradient,
            'Step Size': step,
            'Error': error
        }
        log = log.append(log_info, ignore_index=True)
        solution = [k, x, gradient, step, error]
        
        k += 1
    return(log, solution)


def gd_fixed_step(Q, c, x, step, tolerance, N):
    
    #Defining the initial values
    k=1
    error = 100
    
    #Data frame to store each iteration data
    log = pd.DataFrame(columns = ['Iteration', 'Xk', 'Xk+1', 'Pk', 'Step Size', 'Error'])
    
    while (error > tolerance) & (k <= N):
        x_init = x
        gradient = (np.matmul(Q, x) + c)
        step = step
        x = x - step*gradient
        error = np.linalg.norm(gradient)
        
        log_info = {
            'Iteration': k,
            'Xk': x_init,
            'Xk+1': x,
            'Pk': gradient,
            'Step Size': step,
            'Error': error
        }
        log = log.append(log_info, ignore_index=True)
        solution = [k, x, gradient, step, error]
        
        k += 1
    return(log, solution)

def gd_variable_step(Q, c, x, tolerance, N):
    
    #Defining the initial values
    k=1
    error = 100
    
    #Data frame to store each iteration data
    log = pd.DataFrame(columns = ['Iteration', 'Xk', 'Xk+1', 'Pk', 'Step Size', 'Error'])
    
    while (error > tolerance) & (k <= N):
        x_init = x
        gradient = (np.matmul(Q, x) + c)
        step = 1/k
        x = x - step*gradient
        error = np.linalg.norm(gradient)
        
        log_info = {
            'Iteration': k,
            'Xk': x_init,
            'Xk+1': x,
            'Pk': gradient,
            'Step Size': step,
            'Error': error
        }
        log = log.append(log_info, ignore_index=True)
        solution = [k, x, gradient, step, error]
        
        k += 1
    return(log, solution)
