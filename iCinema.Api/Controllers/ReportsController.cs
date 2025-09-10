using iCinema.Application.DTOs.Reports;
using iCinema.Application.Features.Reports.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class ReportsController(IMediator mediator) : ControllerBase
{
    [HttpPost("generate")]
    public async Task<IActionResult> Generate([FromBody] ReportRequestDto request)
    {
        var result = await mediator.Send(new GenerateReportQuery(request));
        return Ok(result);
    }
}
