%Read the image
image = imread('C:\Users\K-Chak\Google Drive\NYU\Spring 2017\Computer Vision\Assignment\1\Problem 4\check_1.jpg');
imshow(image);

%Measure the pixel coordinates of the 6 points on the image. 
[imageX,imageY] = ginput(6);

%Use excel to caculate the P Matrix and then read as well. 
P = xlsread('C:\Users\K-Chak\Google Drive\NYU\Spring 2017\Computer Vision\Assignment\1\Problem 4\pmatrix.xlsx');

%Find the values of m1,m2,m3 or what we say the M matrix using the following three statements.
[U,S,V] = svd(P);
[min_value, min_index] = min(diag(S(1:12,1:12)));
m = V(1:12, min_index);

M = [ m(1:4)'; m(5:8)'; m(9:12)'];

%Extract the a1, a2 and a3 from the M matrix
a1 = M(1,1:3)';
a2 = M(2,1:3)';
a3 = M(3,1:3)';

%Calculate rho
rho = 1/norm(a3);
r3 = rho.*a3;

%To find the parameters we need the following values, so we calculate them here. 
dot_a1a3 = dot(a1,a3);
dot_a2a3 = dot(a2,a3);
cross_a1a3 = cross(a1,a3);
cross_a2a3 = cross(a2,a3);

%Calculate the intrinsic parameters
u0 = rho*rho*dot_a1a3;
v0 = rho*rho*dot_a2a3;
theta =acosd( -(dot(cross_a1a3,cross_a2a3))/((norm(cross_a1a3))*norm(cross_a2a3)));
alpha = rho*rho*norm(cross_a1a3)*sin(theta);
beta = rho*rho*norm(cross_a2a3)*sin(theta);

%Combine all these intrinsic parameters into 1 single vector
Intrinsic = [u0;v0;theta;alpha;beta];

%Calculate the rotation matrix components, r1 and r2. r3 was caculated earlier
r1 = cross_a1a3./norm(cross_a1a3);
r2 = cross(r3,r1);

%Form the rotation matrix using r1,r2 and r3
Rotation = [r1';r2';r3'];

%Extract the translational component from the M matrix, that is the last column
b = M(1:3,4);

%Calculate the K matrix to further calculate the Translation matrix
K =	[	
		alpha 	-alpha*cot(theta)	u0;
		0 	beta/sin(theta)		v0;
		0 	0			1
	];

%Using the K matrix, get the translational matrix
Translation = rho*inv(K)*b;

%These are the world coordinates of the 6 points
world = [	
		37	68	0	1;
		121.5	96	0	1;
		93.5	181	0	1;
		0	212	150	1;
		0	154.7	37	1;
		0	98.3	122	1;
	];

%Calculate the pixels using the M matrix for each point of the world
for(i=1:6)
	image_reconstructed = M*world(i,:)';
	imageCalculatedX(i)=image_reconstructed(1)/image_reconstructed(3);
	imageCalculatedY(i)=image_reconstructed(2)/image_reconstructed(3);
end;

imageCalculatedX = imageCalculatedX';
errorX = imageCalculatedX - imageX;

imageCalculatedY = imageCalculatedY';
errorY = imageCalculatedY - imageY;

%Calculating the final norm error for each point
for i =1:6
	finalError(i) = norm([errorX(i) errorY(i)]);
end;