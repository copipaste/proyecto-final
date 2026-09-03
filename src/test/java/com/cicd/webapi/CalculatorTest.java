package com.cicd.webapi;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {

    private Calculator calculator;

    @BeforeEach
    void setUp() {
        calculator = new Calculator();
    }

    @Test
    void testAdd() {
        assertEquals(5, calculator.add(2, 3));
        assertEquals(-1, calculator.add(2, -3));
        assertEquals(0, calculator.add(0, 0));
    }

    @Test
    void testSubtract() {
        assertEquals(2, calculator.subtract(5, 3));
        assertEquals(8, calculator.subtract(5, -3));
    }

    @Test
    void testMultiply() {
        assertEquals(15, calculator.multiply(3, 5));
        assertEquals(-15, calculator.multiply(3, -5));
        assertEquals(0, calculator.multiply(0, 5));
    }

    @Test
    void testDivide() {
        assertEquals(2.5, calculator.divide(5.0, 2.0));
        assertEquals(-2.0, calculator.divide(6.0, -3.0));
    }

    @Test
    void testDivideByZeroThrowsException() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> calculator.divide(10.0, 0.0)
        );
        assertEquals("Denominator cannot be zero", exception.getMessage());
    }

    @Test
    void testFactorial() {
        assertEquals(1.0, calculator.factorial(0));
        assertEquals(1.0, calculator.factorial(1));
        assertEquals(2.0, calculator.factorial(2));
        assertEquals(6.0, calculator.factorial(3));
        assertEquals(24.0, calculator.factorial(4));
        assertEquals(120.0, calculator.factorial(5));
    }

    @Test
    void testFactorialNegativeThrowsException() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> calculator.factorial(-1)
        );
        assertEquals("Negative numbers are not allowed", exception.getMessage());
    }
}