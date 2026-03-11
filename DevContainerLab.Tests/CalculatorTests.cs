using DevContainerLab.App;

namespace DevContainerLab.Tests;

public class CalculatorTests
{
    [Fact]
    public void Add_ReturnsCorrectSum()
    {
        Assert.Equal(5, Calculator.Add(2, 3));
    }

    [Fact]
    public void Average_ReturnsCorrectAverage()
    {
        int[] numbers = [10, 20, 30];
        double result = Calculator.Average(numbers);
        Assert.Equal(20.0, result);
    }
}
