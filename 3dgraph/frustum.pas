{
  Copyright 2005-2008 Michalis Kamburelis.

  This file is part of "Kambi VRML game engine".

  "Kambi VRML game engine" is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  "Kambi VRML game engine" is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with "Kambi VRML game engine"; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  ----------------------------------------------------------------------------
}

{ Frustum object and helpers.
  Frustum is represented as @link(TFrustum) type,
  basically just 6 plane equations. }
unit Frustum;

interface

uses VectorMath, Boxes3d;

type
  { Order of planes of TFrustum.

    (This order is the same as the order of params to
    procedure FrustumProjMatrix and OpenGL's glFrustum routine.
    Article [http://www2.ravensoft.com/users/ggribb/plane%20extraction.pdf]
    has swapped bottom and top positions). }
  TFrustumPlane = (fpLeft, fpRight, fpBottom, fpTop, fpNear, fpFar);

  TFrustumPointsSingle = packed array [0..7] of packed record
    case Integer of
      0: (XYZ: TVector3Single; W: Single);
      1: (XYZW: TVector4Single);
  end;

  TFrustumPointsDouble = packed array [0..7] of packed record
    case Integer of
      0: (XYZ: TVector3Double; W: Double);
      1: (XYZW: TVector4Double);
  end;

const
  FrustumPointsQuadsIndexes: array[TFrustumPlane, 0..3]of LongWord =
  ( (0, 3, 7, 4),
    (1, 2, 6, 5),
    (2, 3, 7, 6),
    (0, 1, 5, 4),
    (0, 1, 2, 3),
    (4, 5, 6, 7) );

  { Useful if you want to draw frustum obtained from
    TFrustum.CalculatePoints.

    It's guaranteed that the first 4 items
    touch only the first 4 (near plane) points of the frustum --- useful
    if you want to draw only the near plane rect. For ZFarInfinity,
    other points may be in infinity. }
  FrustumPointsLinesIndexes: array[0..11, 0..1]of LongWord =
  ( (0, 1), (1, 2), (2, 3), (3, 0),
    (4, 5), (5, 6), (6, 7), (7, 4),
    (0, 4), (1, 5), (2, 6), (3, 7)
  );

type
  { See @link(TFrustum.SphereCollisionPossible) for description
    what each value of this type means. }
  TFrustumCollisionPossible =
  ( fcNoCollision,
    fcSomeCollisionPossible,
    fcInsideFrustum );

  { Viewing frustum, defined as 6 plane equations.
    This object allows you to calculate and operate on frustum.
    Frustums with far plane in infinity (typically used in conjunction
    with shadow volumes) are fully supported.

    We define this using old-style "object", to have comfort and low-overhead
    at the same time. }
  TFrustum = object
  private
    procedure NormalizePlanes;
  public
    { Calculate frustum, knowing the combined matrix (modelview * projection). }
    constructor Init(const Matrix: TMatrix4Single);

    { Calculate frustum, knowing projection and modelview matrices.
      This is equivalent to 1-parameter Init
      with Matrix = ModelviewMatrix * ProjectionMatrix.
      This way you can get from OpenGL your two matrices (modelview
      and projection) (or you can calculate them using routines in this
      unit like @link(FrustumProjMatrix)), then pass them to this routine
      and you get your current viewing frustum. }
    constructor Init(const ProjectionMatrix, ModelviewMatrix: TMatrix4Single);

    { Six planes defining the frustum.
      Direction vectors of these planes must point to the inside of the frustum.
      Currently, they are always normalized.

      Note that if projection has far plane in infinity (indicated by
      ZFarInfinity) then the far plane will be invalid ---
      first three values of it's equation will be 0. }
    Planes: array [TFrustumPlane] of TVector4Single;

    ZFarInfinity: boolean;

    { This calculates 8 points of Frustum. These points are simply
      calculated doing ThreePlanesIntersectionPoint on appropriate planes.

      Using these points you can easily draw given frustum on screen.
      Use FrustumPointsQuadsIndexes to obtain indexes to FrustumPoints.
      E.g. using OpenGL use code like this:

        glEnableClientState(GL_VERTEX_ARRAY);
          glVertexPointer(4, GL_FLOAT / GL_DOUBLE, 0, @@FrustumPoints);

          glDrawElements(GL_QUADS,
            SizeOf(FrustumPointsQuadsIndexes) div SizeOf(LongWord),
            GL_UNSIGNED_INT, @@FrustumPointsQuadsIndexes);
          or
          glDrawElements(GL_LiNES,
            SizeOf(FrustumPointsLinesIndexes) div SizeOf(LongWord),
            GL_UNSIGNED_INT, @@FrustumPointsLinesIndexes);

        glDisableClientState(GL_VERTEX_ARRAY);

      This works with Ok with far plane in infinity.
      Then the 4 points of the far plane will be "in infinity",
      that is will have 4th component set to zero. Or, equivalently,
      they will be directions. Homogenous coordinates allow us for this,
      and in fact you can just render such points without any problems
      in OpenGL.

      @italic(Question:) Should I use TFrustumPointsSingle or TFrustumPointsDouble ?
      Short answer: use Double. Tests show that while keeping type TFrustum
      based on Single type is sufficient, calculating FrustumPoints
      on Single type is *not* sufficient, practical example: run
      @preformatted(
        view3dscene kambi_vrml_test_suite/vrml_2/cones.wrl
      )
      and jump to viewpoint named "Frustum needs double-precision".

      Turn "Show viewing frustum" on and you will see that frustum
      looks good. But when you change implementation of view3dscene.pasprogram
      to use TFrustumPointsSingle (and change GL_DOUBLE at glVertexPointer
      to GL_FLOAT) then frustum will look bad (both near and far quads
      will look obviously slightly assymetrical).

      @raises(EPlanesParallel If Frustum doesn't have planes of any
        valid frustum.)
    }
    procedure CalculatePoints(out FrustumPoints: TFrustumPointsSingle); overload;
    procedure CalculatePoints(out FrustumPoints: TFrustumPointsDouble); overload;

    { Checks for collision between frustum and sphere.

      Check is done fast, but is not accurate, that's why this function's
      name contains "CollisionPossible". It returns:

      fcNoCollision when it's sure that there no collision,

      fcSomeCollisionPossible when some collision is possible,
      but nothing is sure. There *probably* is some collision,
      but it's not difficult to find some special situations where there
      is no collision but this function answers fcSomeCollisionPossible.
      There actually may be either no collision,
      or only part of sphere may be inside frustum.

      Note that it's guaranteed that if the whole sphere
      (or the whole box in case of Box3dCollisionPossible)
      is inside the frustum that fcInsideFrustum will be returned,
      not fcSomeCollisionPossible.

      fcInsideFrustum if sphere is for sure inside the frustum.

      So this function usually cannot be used for some precise collision
      detection, but it can be used for e.g. optimizing your graphic engine
      by doing frustum culling. Note that fcInsideFrustum result
      is often useful when you're comparing your frustum with
      bounding volume of some tree (e.g. octree) node: fcInsideFrustum
      tells you that not only this node collides with frustum,
      but also all it's children nodes collide for sure with frustum.
      This allows you to save some time instead of doing useless
      recursion down the tree.

      Many useful optimization ideas used in implementing this function
      were found at
      [http://www.flipcode.com/articles/article_frustumculling.shtml].

      @seealso TFrustum.Box3dCollisionPossible
    }
    function SphereCollisionPossible(
      const SphereCenter: TVector3Single; const SphereRadiusSqr: Single):
      TFrustumCollisionPossible;

    { This is like @link(TFrustum.SphereCollisionPossible)
      but it only returns true (when TFrustum.SphereCollisionPossible
      would return fcSomeCollisionPossible or fcInsideFrustum)
      or false (when TFrustum.SphereCollisionPossible
      would return fcNoCollision).

      Consequently, it runs a (very little) faster.
      Just use this if you don't need to distinct between
      fcSomeCollisionPossible or fcInsideFrustum cases. }
    function SphereCollisionPossibleSimple(
      const SphereCenter: TVector3Single; const SphereRadiusSqr: Single):
      boolean;

    { This is equivalent to @link(SphereCollisionPossible),
      but here it takes a box instead of a sphere. }
    function Box3dCollisionPossible(
      const Box: TBox3d): TFrustumCollisionPossible;

    { This is like @link(Box3dCollisionPossible)
      but it returns true when Box3dCollisionPossible
      would return fcSomeCollisionPossible or fcInsideFrustum.
      Otherwise (when Box3dCollisionPossible would return
      fcNoCollision) this returns false.

      So this returns less detailed result, but is a little faster. }
    function Box3dCollisionPossibleSimple(
      const Box: TBox3d): boolean;

    function Move(const M: TVector3Single): TFrustum;
    procedure MoveTo1st(const M: TVector3Single);

    { Is Direction (you can think of it as a "point infinitely away in direction
      Direction", e.g. the sun) within a frustum ? Note that this ignores
      near/far planes of the frustum, only checking the 4 side planes. }
    function DirectionInside(const Direction: TVector3Single): boolean;
  end;
  PFrustum = ^TFrustum;

implementation

constructor TFrustum.Init(const Matrix: TMatrix4Single);
begin
  { Based on [http://www2.ravensoft.com/users/ggribb/plane%20extraction.pdf].
    Note that position of bottom and top planes in array Frustum is swapped
    in my code. }

  Planes[fpLeft][0] := Matrix[0][3] + Matrix[0][0];
  Planes[fpLeft][1] := Matrix[1][3] + Matrix[1][0];
  Planes[fpLeft][2] := Matrix[2][3] + Matrix[2][0];
  Planes[fpLeft][3] := Matrix[3][3] + Matrix[3][0];

  Planes[fpRight][0] := Matrix[0][3] - Matrix[0][0];
  Planes[fpRight][1] := Matrix[1][3] - Matrix[1][0];
  Planes[fpRight][2] := Matrix[2][3] - Matrix[2][0];
  Planes[fpRight][3] := Matrix[3][3] - Matrix[3][0];

  Planes[fpBottom][0] := Matrix[0][3] + Matrix[0][1];
  Planes[fpBottom][1] := Matrix[1][3] + Matrix[1][1];
  Planes[fpBottom][2] := Matrix[2][3] + Matrix[2][1];
  Planes[fpBottom][3] := Matrix[3][3] + Matrix[3][1];

  Planes[fpTop][0] := Matrix[0][3] - Matrix[0][1];
  Planes[fpTop][1] := Matrix[1][3] - Matrix[1][1];
  Planes[fpTop][2] := Matrix[2][3] - Matrix[2][1];
  Planes[fpTop][3] := Matrix[3][3] - Matrix[3][1];

  Planes[fpNear][0] := Matrix[0][3] + Matrix[0][2];
  Planes[fpNear][1] := Matrix[1][3] + Matrix[1][2];
  Planes[fpNear][2] := Matrix[2][3] + Matrix[2][2];
  Planes[fpNear][3] := Matrix[3][3] + Matrix[3][2];

  Planes[fpFar][0] := Matrix[0][3] - Matrix[0][2];
  Planes[fpFar][1] := Matrix[1][3] - Matrix[1][2];
  Planes[fpFar][2] := Matrix[2][3] - Matrix[2][2];
  Planes[fpFar][3] := Matrix[3][3] - Matrix[3][2];

  { If Planes[fpFar] has really exactly zero vector,
    then far plane is in infinity. }
  ZFarInfinity :=
    (Planes[fpFar][0] = 0) and
    (Planes[fpFar][1] = 0) and
    (Planes[fpFar][2] = 0);

  NormalizePlanes;
end;

procedure TFrustum.NormalizePlanes;
var
  fp, LastPlane: TFrustumPlane;
begin
  LastPlane := High(fp);
  if ZFarInfinity then
    LastPlane := Pred(LastPlane);

  for fp := Low(fp) to LastPlane do
  begin
    NormalizePlaneTo1st(Planes[fp]);

    { Previously we used this hack:

      We know that every plane Planes[fp] is correct, i.e. it's direction
      vector has non-zero length. But sometimes algorithm above calculates
      such vector with very small length, especially for fpFar plane.
      This causes problems when I'm later processing this plane,
      errors cumulate and suddenly something thinks that it has
      a zero-vector, while actually it is (or was) a vector with
      very small (but non-zero) length.

      I could do here
        NormalizePlaneTo1st(Planes[fp]);
      instead, but that would be slow (NormalizePlaneTo1st costs me
      calculating 1 Sqrt).
    if VectorLenSqr(PVector3Single(@Planes[fp])^) < 0.001 then
      VectorScaleTo1st(Planes[fp], 100000);
    }
  end;
end;

constructor TFrustum.Init(
  const ProjectionMatrix, ModelviewMatrix: TMatrix4Single);
begin
  Init(MatrixMult(ProjectionMatrix, ModelviewMatrix));
end;

procedure TFrustum.CalculatePoints(out FrustumPoints: TFrustumPointsSingle);
var
  Camera: TVector3Single;
begin
  { Actually this can be speeded up some day by doing
    TwoPlanesIntersectionLine and then some TryPlaneLineIntersection,
    since current implementation will calculate
    (inside ThreePlanesIntersectionPoint) the same Line0+LineVector many times. }
  FrustumPoints[0].XYZ := ThreePlanesIntersectionPoint(Planes[fpNear], Planes[fpLeft],  Planes[fpTop]);
  FrustumPoints[1].XYZ := ThreePlanesIntersectionPoint(Planes[fpNear], Planes[fpRight], Planes[fpTop]);
  FrustumPoints[2].XYZ := ThreePlanesIntersectionPoint(Planes[fpNear], Planes[fpRight], Planes[fpBottom]);
  FrustumPoints[3].XYZ := ThreePlanesIntersectionPoint(Planes[fpNear], Planes[fpLeft],  Planes[fpBottom]);

  FrustumPoints[0].W := 1;
  FrustumPoints[1].W := 1;
  FrustumPoints[2].W := 1;
  FrustumPoints[3].W := 1;

  if not ZFarInfinity then
  begin
    { 4..7 are in the same order as 0..3, but with "far" instead of "near" }
    FrustumPoints[4].XYZ := ThreePlanesIntersectionPoint(Planes[fpFar], Planes[fpLeft],  Planes[fpTop]);
    FrustumPoints[5].XYZ := ThreePlanesIntersectionPoint(Planes[fpFar], Planes[fpRight], Planes[fpTop]);
    FrustumPoints[6].XYZ := ThreePlanesIntersectionPoint(Planes[fpFar], Planes[fpRight], Planes[fpBottom]);
    FrustumPoints[7].XYZ := ThreePlanesIntersectionPoint(Planes[fpFar], Planes[fpLeft],  Planes[fpBottom]);

    FrustumPoints[4].W := 1;
    FrustumPoints[5].W := 1;
    FrustumPoints[6].W := 1;
    FrustumPoints[7].W := 1;
  end else
  begin
    Camera := ThreePlanesIntersectionPoint(Planes[fpRight], Planes[fpLeft],  Planes[fpTop]);

    FrustumPoints[4].XYZ := VectorSubtract(FrustumPoints[0].XYZ, Camera);
    FrustumPoints[5].XYZ := VectorSubtract(FrustumPoints[1].XYZ, Camera);
    FrustumPoints[6].XYZ := VectorSubtract(FrustumPoints[2].XYZ, Camera);
    FrustumPoints[7].XYZ := VectorSubtract(FrustumPoints[3].XYZ, Camera);

    FrustumPoints[4].W := 0;
    FrustumPoints[5].W := 0;
    FrustumPoints[6].W := 0;
    FrustumPoints[7].W := 0;
  end;
end;

procedure TFrustum.CalculatePoints(out FrustumPoints: TFrustumPointsDouble);
var
  Camera: TVector3Double;
begin
  { Copied from implementation for TFrustumPointsSingle, but here converting
    to double precision. }
  FrustumPoints[0].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpNear]), Vector4Double(Planes[fpLeft]),  Vector4Double(Planes[fpTop]));
  FrustumPoints[1].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpNear]), Vector4Double(Planes[fpRight]), Vector4Double(Planes[fpTop]));
  FrustumPoints[2].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpNear]), Vector4Double(Planes[fpRight]), Vector4Double(Planes[fpBottom]));
  FrustumPoints[3].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpNear]), Vector4Double(Planes[fpLeft]),  Vector4Double(Planes[fpBottom]));

  FrustumPoints[0].W := 1;
  FrustumPoints[1].W := 1;
  FrustumPoints[2].W := 1;
  FrustumPoints[3].W := 1;

  if not ZFarInfinity then
  begin
    FrustumPoints[4].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpFar]), Vector4Double(Planes[fpLeft]),  Vector4Double(Planes[fpTop]));
    FrustumPoints[5].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpFar]), Vector4Double(Planes[fpRight]), Vector4Double(Planes[fpTop]));
    FrustumPoints[6].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpFar]), Vector4Double(Planes[fpRight]), Vector4Double(Planes[fpBottom]));
    FrustumPoints[7].XYZ := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpFar]), Vector4Double(Planes[fpLeft]),  Vector4Double(Planes[fpBottom]));

    FrustumPoints[4].W := 1;
    FrustumPoints[5].W := 1;
    FrustumPoints[6].W := 1;
    FrustumPoints[7].W := 1;
  end else
  begin
    Camera := ThreePlanesIntersectionPoint(Vector4Double(Planes[fpRight]), Vector4Double(Planes[fpLeft]),  Vector4Double(Planes[fpTop]));

    FrustumPoints[4].XYZ := VectorSubtract(FrustumPoints[0].XYZ, Camera);
    FrustumPoints[5].XYZ := VectorSubtract(FrustumPoints[1].XYZ, Camera);
    FrustumPoints[6].XYZ := VectorSubtract(FrustumPoints[2].XYZ, Camera);
    FrustumPoints[7].XYZ := VectorSubtract(FrustumPoints[3].XYZ, Camera);

    FrustumPoints[4].W := 0;
    FrustumPoints[5].W := 0;
    FrustumPoints[6].W := 0;
    FrustumPoints[7].W := 0;
  end;
end;

function TFrustum.SphereCollisionPossible(
  const SphereCenter: TVector3Single; const SphereRadiusSqr: Single):
  TFrustumCollisionPossible;
var
  fp, LastPlane: TFrustumPlane;
  Distance, SqrRealDistance: Single;
  InsidePlanesCount: Cardinal;
begin
  InsidePlanesCount := 0;

  LastPlane := High(FP);
  Assert(LastPlane = fpFar);

  { If the frustum has far plane in infinity, then ignore this plane.
    Inc InsidePlanesCount, since the sphere is inside this infinite plane. }
  if ZFarInfinity then
  begin
    LastPlane := Pred(LastPlane);
    Inc(InsidePlanesCount);
  end;

  { The logic goes like this:
      if sphere is on the "outside" of *any* of 6 planes, result is NoCollision
      if sphere is on the "inside" of *all* 6 planes, result is InsideFrustum
      else SomeCollisionPossible.

    Ideas based on
    [http://www.flipcode.com/articles/article_frustumculling.shtml]
    Version below is even better optimized: in case sphere
    intersects with one plane, but is outside another plane,
    their version may answer "intersection" (equivalent to my
    SomeCollisionPossible), without realizing that actually a better
    answer, NoCollision, exists. }

  { For the sake of maximum speed, I'm not using here things like
    VectorDotProduct or PointToPlaneDistanceSqr }
  for fp := Low(fp) to LastPlane do
  begin
   { This is not a true distance since this is signed }
   Distance := Planes[fp][0] * SphereCenter[0] +
               Planes[fp][1] * SphereCenter[1] +
               Planes[fp][2] * SphereCenter[2] +
               Planes[fp][3];

   SqrRealDistance := Sqr(Distance);

   if (Distance < 0) and (SqrRealDistance > SphereRadiusSqr) then
   begin
    Result := fcNoCollision;
    Exit;
   end else
   if SqrRealDistance >= SphereRadiusSqr then
    Inc(InsidePlanesCount);
  end;

  if InsidePlanesCount = 6 then
    Result := fcInsideFrustum else
    Result := fcSomeCollisionPossible;
end;

function TFrustum.SphereCollisionPossibleSimple(
  const SphereCenter: TVector3Single; const SphereRadiusSqr: Single):
  boolean;
var
  fp: TFrustumPlane;
  Distance, SqrRealDistance: Single;
  LastPlane: TFrustumPlane;
begin
  LastPlane := High(FP);
  Assert(LastPlane = fpFar);

  { If the frustum has far plane in infinity, then ignore this plane. }
  if ZFarInfinity then
    LastPlane := Pred(LastPlane);

  for fp := Low(fp) to LastPlane do
  begin
   { This is not a true distance since this is signed }
   Distance := Planes[fp][0] * SphereCenter[0] +
               Planes[fp][1] * SphereCenter[1] +
               Planes[fp][2] * SphereCenter[2] +
               Planes[fp][3];

   SqrRealDistance := Sqr(Distance);

   if (Distance < 0) and (SqrRealDistance > SphereRadiusSqr) then
   begin
    Result := false;
    Exit;
   end;
  end;

  Result := true;
end;

function TFrustum.Box3dCollisionPossible(
  const Box: TBox3d): TFrustumCollisionPossible;

{ Note: I tried to optimize this function,
  since it's crucial for TOctree.EnumerateCollidingOctreeItems,
  and this is crucial for TVRMLGLScene.RenderFrustumOctree,
  and this is crucial for overall speed of rendering. }

var
  fp: TFrustumPlane;
  InsidePlanesCount: Cardinal;
  LastPlane: TFrustumPlane;
begin
  InsidePlanesCount := 0;

  LastPlane := High(FP);
  Assert(LastPlane = fpFar);

  { If the frustum has far plane in infinity, then ignore this plane.
    Inc InsidePlanesCount, since the box is inside this infinite plane. }
  if ZFarInfinity then
  begin
    LastPlane := Pred(LastPlane);
    Inc(InsidePlanesCount);
  end;

  { The logic goes like this:
      if box is on the "outside" of *any* of 6 planes, result is NoCollision
      if box is on the "inside" of *all* 6 planes, result is InsideFrustum
      else SomeCollisionPossible. }

  for fp := Low(fp) to LastPlane do
  begin
    { Don't be confused by names below: pcOutside means that box
      is where Planes[fp] normal points, which means *inside* the frustum... }
    case Box3dPlaneCollision(Box, Planes[fp]) of
      pcInside: Exit(fcNoCollision);
      pcOutside: Inc(InsidePlanesCount);
    end;
  end;

  if InsidePlanesCount = 6 then
    Result := fcInsideFrustum else
    Result := fcSomeCollisionPossible;
end;

function TFrustum.Box3dCollisionPossibleSimple(
  const Box: TBox3d): boolean;

{ Implementation is obviously based on
  TFrustum.Box3dCollisionPossible above, see there for more comments. }

var
  fp: TFrustumPlane;
  LastPlane: TFrustumPlane;
begin
  LastPlane := High(FP);
  Assert(LastPlane = fpFar);

  { If the frustum has far plane in infinity, then ignore this plane. }
  if ZFarInfinity then
    LastPlane := Pred(LastPlane);

  for fp := Low(fp) to LastPlane do
    { Again, don't be confused by name "Inside" below: pcInside
      means that box is where Planes[fp] inverted normal points,
      which means *outside* the frustum... }
    if Box3dPlaneCollisionInside(Box, Planes[fp]) then
      Exit(false);

  Result := true;
end;

function TFrustum.Move(const M: TVector3Single): TFrustum;
begin
  Result.Planes[fpLeft  ] := PlaneMove(Planes[fpLeft]  , M);
  Result.Planes[fpRight ] := PlaneMove(Planes[fpRight] , M);
  Result.Planes[fpBottom] := PlaneMove(Planes[fpBottom], M);
  Result.Planes[fpTop   ] := PlaneMove(Planes[fpTop]   , M);
  Result.Planes[fpNear  ] := PlaneMove(Planes[fpNear]  , M);
  { This is Ok for frustum with infinite far plane, since
    PlaneMove will simply keep the far plane invalid }
  Result.Planes[fpFar   ] := PlaneMove(Planes[fpFar]   , M);
  Result.ZFarInfinity := ZFarInfinity;
  Result.NormalizePlanes;
end;

procedure TFrustum.MoveTo1st(const M: TVector3Single);
begin
  PlaneMoveTo1st(Planes[fpLeft]  , M);
  PlaneMoveTo1st(Planes[fpRight] , M);
  PlaneMoveTo1st(Planes[fpBottom], M);
  PlaneMoveTo1st(Planes[fpTop]   , M);
  PlaneMoveTo1st(Planes[fpNear]  , M);
  { This is Ok for frustum with infinite far plane, since
    PlaneMove will simply keep the far plane invalid }
  PlaneMoveTo1st(Planes[fpFar]   , M);
  NormalizePlanes;
end;

function TFrustum.DirectionInside(const Direction: TVector3Single): boolean;
begin
  { First we check fpTop, since this (usually?) has the highest chance
    of failing (when Direction is direction of sun high in the sky) }
  Result := ( Planes[fpTop][0] * Direction[0] +
              Planes[fpTop][1] * Direction[1] +
              Planes[fpTop][2] * Direction[2] >= 0 ) and
            ( Planes[fpLeft][0] * Direction[0] +
              Planes[fpLeft][1] * Direction[1] +
              Planes[fpLeft][2] * Direction[2] >= 0 ) and
            ( Planes[fpRight][0] * Direction[0] +
              Planes[fpRight][1] * Direction[1] +
              Planes[fpRight][2] * Direction[2] >= 0 ) and
            ( Planes[fpBottom][0] * Direction[0] +
              Planes[fpBottom][1] * Direction[1] +
              Planes[fpBottom][2] * Direction[2] >= 0 );
end;

end.
