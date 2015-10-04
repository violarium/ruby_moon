# Examples related to sign in/out process for feature specs, like sign in required and so on.

shared_examples 'sign in required' do
  it 'should show sign in page with error message' do
    expect(page).to have_title('Sign in')
    expect(page).to have_content('You are to sign in!')
  end
end
