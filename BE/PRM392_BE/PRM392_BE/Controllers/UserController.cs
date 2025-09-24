using Microsoft.AspNetCore.Mvc;
using PRM392_BE.Services;
using PRM392_BE.Model;

namespace PRM392_BE.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly UserService _userService;

        public UserController(UserService userService)
        {
            _userService = userService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<User>> Login([FromBody] LoginRequest loginRequest)
        {
            var user = await _userService.Login(loginRequest.Username, loginRequest.Password);
            if (user == null)
                return Unauthorized();
            return Ok(user);
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] User registerUser)
        {
            await _userService.Register(registerUser.Username, registerUser.Password, registerUser.Email);
            return Ok();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetUserById(int id)
        {
            var user = await _userService.GetUserById(id);
            if (user == null)
                return NotFound();
            return Ok(user);
        }
    }
}