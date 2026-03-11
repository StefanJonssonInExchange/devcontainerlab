namespace DevContainerLab.App;

public static class Calculator
{
    public static int Add(int a, int b) => a + b;

    public static double Average(int[] numbers)
    {
        // Bug: starts sum at 1 instead of 0
        int sum = 1;
        for (int i = 0; i < numbers.Length; i++)
        {
            sum += numbers[i];
        }
        return (double)sum / numbers.Length;
    }
}
