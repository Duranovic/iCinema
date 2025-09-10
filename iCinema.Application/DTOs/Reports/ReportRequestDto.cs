using System.ComponentModel.DataAnnotations;

namespace iCinema.Application.DTOs.Reports;

public class ReportRequestDto
{
    [Required]
    public ReportType ReportType { get; set; }
    
    [Required]
    public DateTime DateFrom { get; set; }
    
    [Required]
    public DateTime DateTo { get; set; }
}

public enum ReportType
{
    MovieReservations,
    MovieSales,
    HallReservations,
    CinemaReservations
}
