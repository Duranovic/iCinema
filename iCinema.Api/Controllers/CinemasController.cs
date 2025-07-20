using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Controllers;

public class CinemasController : Controller
{
    // GET
    public IActionResult Index()
    {
        return View();
    }
}