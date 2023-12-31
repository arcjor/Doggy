using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Doggy.Models;

namespace Doggy.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DogController : ControllerBase
    {
        private readonly DogContext _context;

        public DogController(DogContext context)
        {
            _context = context;
        }

        // GET: api/Dog
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Dog>>> GetDogs()
        {
          if (_context.Dogs == null)
          {
              return NotFound();
          }
            return await _context.Dogs.ToListAsync();
        }

        // GET: api/Dog/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Dog>> GetDog(long id)
        {
          if (_context.Dogs == null)
          {
              return NotFound();
          }
            var dog = await _context.Dogs.FindAsync(id);

            if (dog == null)
            {
                return NotFound();
            }

            return dog;
        }

        // PUT: api/Dog/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutDog(long id, Dog dog)
        {
            if (id != dog.Id)
            {
                return BadRequest();
            }

            _context.Entry(dog).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!DogExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Dog
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Dog>> PostDog(Dog dog)
        {
          if (_context.Dogs == null)
          {
              return Problem("Entity set 'DogContext.Dogs'  is null.");
          }
            _context.Dogs.Add(dog);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetDog), new { id = dog.Id }, dog);
        }

        // DELETE: api/Dog/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteDog(long id)
        {
            if (_context.Dogs == null)
            {
                return NotFound();
            }
            var dog = await _context.Dogs.FindAsync(id);
            if (dog == null)
            {
                return NotFound();
            }

            _context.Dogs.Remove(dog);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool DogExists(long id)
        {
            return (_context.Dogs?.Any(e => e.Id == id)).GetValueOrDefault();
        }
    }
}
