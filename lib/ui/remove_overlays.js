const fs = require('fs');
let c = fs.readFileSync('lib/ui/game_screen.dart', 'utf8');
const methods = [
  'Widget _buildStartOverlay(',
  'Widget _buildOpponentInfoBar(',
  'Widget _buildSidePanel(',
  'Color _eventColor(',
  'Widget _buildCardSelectOverlay(',
  'Widget _buildYakuAnnounce(',
  'Widget _buildYakuProgress(',
  'Widget _yakuBar(',
  'Widget _buildAiGoStopAnimation(',
  'Widget _buildGoStopOverlay(',
  'Widget _buildRoundEndOverlay(',
  'Widget _gameOverStatRow(',
  'Widget _resultBadge('
];

methods.forEach(n => {
  let i = c.indexOf('  ' + n);
  if (i === -1) i = c.indexOf(n);
  if (i !== -1) {
    let s = c.indexOf('{', i);
    let count = 1;
    let j = s + 1;
    while (count > 0 && j < c.length) {
      if (c[j] === '{') count++;
      if (c[j] === '}') count--;
      j++;
    }
    // Delete from the start of the line
    let lineStart = c.lastIndexOf('\n', i) + 1;
    c = c.substring(0, lineStart) + c.substring(j);
  }
});

fs.writeFileSync('lib/ui/game_screen.dart', c, 'utf8');
console.log('done, new size:', c.length);
