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
    
    public static class Directors
    {
        public static readonly Guid ChristopherNolan = Guid.Parse("33333333-3333-3333-3333-333333333331");
        public static readonly Guid DenisVilleneuve = Guid.Parse("33333333-3333-3333-3333-333333333332");
        public static readonly Guid GretaGerwig = Guid.Parse("33333333-3333-3333-3333-333333333333");
        public static readonly Guid MartinScorsese = Guid.Parse("33333333-3333-3333-3333-333333333334");
    }

    public static class Actors
    {
        public static readonly Guid LeonardoDiCaprio = Guid.Parse("44444444-4444-4444-4444-444444444441");
        public static readonly Guid CillianMurphy = Guid.Parse("44444444-4444-4444-4444-444444444442");
        public static readonly Guid RyanGosling = Guid.Parse("44444444-4444-4444-4444-444444444443");
        public static readonly Guid EmilyBlunt = Guid.Parse("44444444-4444-4444-4444-444444444444");
        public static readonly Guid MargotRobbie = Guid.Parse("44444444-4444-4444-4444-444444444445");
        public static readonly Guid RobertDeNiro = Guid.Parse("44444444-4444-4444-4444-444444444446");
    }
}