namespace iCinema.Infrastructure.Persistence.Seed;

public static class SeedConstants
{
    public static class Countries
    {
        public static readonly Guid BosniaAndHerzegovina = Guid.Parse("11111111-1111-1111-1111-111111111111");
        public static readonly Guid Croatia = Guid.Parse("11111111-1111-1111-1111-111111111112");
    }
    
    public static class Cities
    {
        public static readonly Guid Sarajevo = Guid.Parse("22222222-2222-2222-2222-222222222221");
        public static readonly Guid Mostar = Guid.Parse("22222222-2222-2222-2222-222222222222");
        public static readonly Guid BanjaLuka = Guid.Parse("22222222-2222-2222-2222-222222222223");
        public static readonly Guid Zagreb = Guid.Parse("22222222-2222-2222-2222-222222222231");
        public static readonly Guid Pula = Guid.Parse("22222222-2222-2222-2222-222222222232");
        public static readonly Guid Split = Guid.Parse("22222222-2222-2222-2222-222222222233");
    }
}