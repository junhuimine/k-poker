/// K-Poker 골드 경제 밸런스 최종 시뮬레이션
/// 파라미터: 50G 시작, 12/pt, 0% 스케일링, 패배 골드 손실 없음
import 'dart:math';

void main() {
  final rng = Random(42);
  const n = 5000;
  const startG = 50;
  const gpp = 12;
  const scaling = 0.0;

  // 딜링 7장으로 변경 → 턴 수 감소 → 기대 점수 약간 하향
  final scores = {1:[2,5], 2:[2,6], 3:[3,7], 4:[3,9], 5:[4,11], 6:[4,13]};
  final wr = {1:0.75, 2:0.65, 3:0.55, 4:0.50, 5:0.45, 6:0.40};

  Map<int,List<int>> ends={}, wi={}, bu={}, cu={};
  for(int s=1;s<=6;s++){ends[s]=[];wi[s]=[];bu[s]=[];cu[s]=[];}
  int alive6=0;

  for(int i=0;i<n;i++){
    int gold=startG,ws=0,ci=0;
    bool alive=true;

    for(int st=1;st<=6&&alive;st++){
      int sb=0;
      for(int r=0;r<4;r++){
        if(rng.nextDouble()<wr[st]!){
          final s2=scores[st]![0]+rng.nextInt(scores[st]![1]-scores[st]![0]+1);
          final g=(gpp*(1+(st-1)*scaling)).round();
          int earned=s2*g;
          ws++;if(ws%3==0)earned+=50;
          gold+=earned;
          wi[st]!.add(earned);

          // 전략적 구매: 가장 싼 1개만
          final price=_cheapest(st,rng);
          if(gold>=price){gold-=price;sb++;ci++;}
        } else {
          ws=0;
          // 패배 시 골드 손실 없음!
          if(rng.nextDouble()<0.05) alive=false; // 파산만 체크
        }
      }
      ends[st]!.add(gold);bu[st]!.add(sb);cu[st]!.add(ci);
      if(st==6&&alive) alive6++;
    }
  }

  print('═══════════════════════════════════════════════════');
  print(' K-Poker 최종 밸런스 (50G, 12/pt, 0%sc, 패배손실無)');
  print(' 딜링 7장 기준, ${n}회 시뮬레이션');
  print('═══════════════════════════════════════════════════');
  print('');
  print('Stg │ 골드잔액 │ 1회수입 │ 구매/stg │ 누적 │ 체감');
  print('────┼─────────┼────────┼──────────┼──────┼──────');
  for(int s=1;s<=6;s++){
    final e=_a(ends[s]!),w=_a(wi[s]!),b=_a(bu[s]!),c=_a(cu[s]!);
    String f;
    if(w<50)f='❌ 적음';
    else if(w<80)f='😰 모자람';
    else if(w<100)f='🎯 빠듯';
    else if(w<150)f='😊 여유';
    else f='💰 넉넉';
    print(' $s  │ ${e.toString().padLeft(6)}G │ ${w.toString().padLeft(5)}G │    ${b.toString().padLeft(2)}개  │  ${c.toString().padLeft(2)}개 │ $f');
  }

  final w1=_a(wi[1]!),cum6=cu[6]!.isNotEmpty?_a(cu[6]!):0;
  print('');
  print(' 📊 S1 1회수입: ${w1}G (Common 90G 기준 ${(w1/90*100).toStringAsFixed(0)}%)');
  print(' 📊 풀런(6stg) 총 스킬: ~${cum6}개');
  print(' 📊 S6 도달률: ${(alive6/n*100).toStringAsFixed(1)}%');
  print('');

  // 광고 보상 시뮬
  print('── 보상형 광고 효과 (향후 모바일) ──');
  print(' 광고 1회 = +80G → S1 1회수입 ${w1}G + 80G = ${w1+80}G');
  print(' → Common(90G) ${w1+80>=90?"✅ 구매 가능":"❌ 여전히 부족"}');
  print(' → 풀런 추가 ~3~4개 스킬 구매 가능');
}

int _cheapest(int st,Random rng){
  final n2=st>=4?4:3;int ch=999;
  for(int i=0;i<n2;i++){final p=_price(st,rng);if(p<ch)ch=p;}
  return ch;
}
int _price(int st,Random rng){
  final roll=rng.nextDouble();
  final c=st<=1?0.70:st<=2?0.55:st<=3?0.40:st<=4?0.25:0.15;
  final r2=st<=1?0.95:st<=2?0.85:st<=3?0.70:st<=4?0.55:0.40;
  final r3=st<=1?1.0:st<=2?0.97:st<=3?0.90:st<=4?0.80:0.70;
  if(roll<c)return 80+rng.nextInt(40);
  if(roll<r2)return 150+rng.nextInt(150);
  if(roll<r3)return 300+rng.nextInt(200);
  return 700+rng.nextInt(100);
}
int _a(List<int> l)=>l.isEmpty?0:(l.reduce((a,b)=>a+b)/l.length).round();
